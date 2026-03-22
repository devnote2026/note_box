import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//ラベルをつけたり外したりする処理。

class LabelService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> toggleLabel(String noteId) async {    
    final uid = _uid;                                 //ラベルをつけたり外したりできるのはログイン済みのユーザーだけ。
    if (uid == null) {
      throw Exception("ログインしていません");
    }

    final labelRef = _db                              // labelRef: 「後からラベルをつけたノートを見返すよう」にノートを保存する場所
        .collection('users')
        .doc(uid)
        .collection('labeledNotes')
        .doc(noteId);

    final noteRef = _db.collection('notes').doc(noteId);  // noteRef: 「実際にラベルをつけたノート本体が保存されている場所」

    await _db.runTransaction((tx) async {
      /// 🔥 ① ノート取得（超重要）
      final noteSnap = await tx.get(noteRef);          // noteRef(実際のノートがある場所)を参考にして「ラベルを押されたノート」を取得する
      if (!noteSnap.exists) {                          // 仮にノートがなければ終わる(例外)
        throw Exception("ノートが存在しません");
      }

      final noteData = noteSnap.data()!;               //取得したノートの投稿主「ラベルされる人」を取得
      final ownerUid = noteData['uid'];

      if (ownerUid == null) {                          //「ラベルされる人」のデータがなければ終わる(例外)
        throw Exception("投稿者が不明です");
      }

      final ownerRef = _db.collection('users').doc(ownerUid);  //ownerRef: これから「ラベルされる人」の情報

      /// 🔥 ② ラベル状態確認
      final labelSnap = await tx.get(labelRef);  //これから「ラベルする人」のラベル済みノートを取得する

      if (labelSnap.exists) {      //もしラベル済みならラベルを消して、ノート本体のラベル数から１減らす
        /// =========================
        /// 🔴 ラベル削除
        /// =========================
        tx.delete(labelRef);

        /// ノートの⭐数 -1（安全対策付き）
        final currentCount = noteData['labelCount'] ?? 0;
        if (currentCount > 0) {
          tx.update(noteRef, {
            'labelCount': FieldValue.increment(-1),
          });
        }

        /// 投稿者のもらった⭐数 -1
        tx.set(ownerRef, {                //「ラベルされる人(ノートの投稿主)」の総ラベル数から１減らす
          'receivedLabelCount': FieldValue.increment(-1),
        }, SetOptions(merge: true));

      } else {                           //ラベル済みでなかった場合
        /// =========================
        /// 🟢 ラベル追加
        /// =========================
        tx.set(labelRef, {               //ラベルしたノートリストに作成時を保存
          'createdAt': FieldValue.serverTimestamp(),
          'noteId': noteId,
          'subject': noteData['subject'],
          'grade': noteData['grade'],
          'department': noteData['department'],
          'noteType': noteData['noteType'],
          'term': noteData['term'],
          'labelCount': noteData['labelCount'] ?? 0,
          'nickname': noteData['nickname'],
          'ownerUid': ownerUid,
          'profileImageUrl': noteData['profileImageUrl']
        });

        /// ノートの⭐数 +1
        tx.set(noteRef, {                //ノートの「ラベルされた数」を１増やす
          'labelCount': FieldValue.increment(1),
        }, SetOptions(merge: true));

        /// 投稿者のもらった⭐数 +1
        tx.set(ownerRef, {               //「ラベルされる人(ノートの投稿主)」の総ラベル数を１増やす。
          'receivedLabelCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
    });
  }
}