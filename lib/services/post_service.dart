import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/post_storage_service.dart';

//投稿を行う処理

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final PostStorageService _postStorage;

  PostService(this._postStorage);

  /// 🔥 noteId生成（typeで分岐）
  String _buildNoteId({
    required String uid,
    required String grade,
    required String department,
    required String subject,
    required String noteType,
    String? term,
  }) {
    if (noteType == "past_exam") {
      return "${uid}_${grade}_${department}_${subject}_${noteType}_${term ?? 'unknown'}";
    } else {
      return "${uid}_${grade}_${department}_${subject}_${noteType}";
    }
  }

  /// 🔥 投稿処理（本番OK版）
  Future<void> createPost({
    required File imageFile,
    required String grade,
    required String department,
    required String subject,
    required String noteType,
    String? term,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Unauthenticated");

    /// 🔥 バリデーション
    if (noteType == "past_exam" && term == null) {
      throw Exception("過去問なのに期間がないよ！");
    }

    final uid = user.uid;

    final userDoc = await _firestore
                            .collection("users")
                            .doc(uid)
                            .get();
   
    final data = userDoc.data() ?? {};
    final nickname = data['nickname'] ?? "名無し";
    final profileImageUrl = data['profileImageUrl'];

    final noteId = _buildNoteId(
      uid: uid,
      grade: grade,
      department: department,
      subject: subject,
      noteType: noteType,
      term: term,
    );

    final noteRef = _firestore.collection('notes').doc(noteId);
    final postRef = noteRef.collection('posts').doc();
    final userRef = _firestore.collection('users').doc(uid);
    final userPostRef = userRef.collection('posts').doc(postRef.id);

    String? imageUrl;

    try {
      /// 🔥 ① 画像アップロード（修正済み）
      imageUrl = await _postStorage.uploadPostImage(
        image: imageFile,
        noteId: noteId,
        postId: postRef.id,
      );

      /// 🔥 ② トランザクション
      await _firestore.runTransaction((tx) async {
        final noteSnap = await tx.get(noteRef);

        /// 🔥 note作成 or 更新
        if (!noteSnap.exists) {
          tx.set(noteRef, {
            'uid': uid,
            'nickname': nickname,
            'profileImageUrl': profileImageUrl,
            'grade': grade,
            'department': department,
            'subject': subject,
            'noteType': noteType,
            'term': noteType == "past_exam" ? term : null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'postCount': 1,
            'labelCount': 0

          });
        } else {
          tx.update(noteRef, {
            'updatedAt': FieldValue.serverTimestamp(),
            'postCount': FieldValue.increment(1),
          });
        }

        /// 🔥 post追加
        tx.set(postRef, {
          'uid': uid,
          'imageUrl': imageUrl,
          'term': noteType == "past_exam" ? term : null,
          'createdAt': FieldValue.serverTimestamp(),
          'nickname': nickname,
          'profileImageUrl': profileImageUrl
        });

        /// 🔥 user統計
        tx.set(userRef, {
          'pageCount': FieldValue.increment(1),
        }, SetOptions(merge: true));

        /// 🔥 user投稿一覧
        tx.set(userPostRef, {
          'noteId': noteId,
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'nickname': nickname,
          'profileImageUrl': profileImageUrl
        });
      });
    } catch (e) {
      /// 🔥 失敗時：画像削除（修正済み）
      if (imageUrl != null) {
        await _postStorage.deletePostImage(imageUrl);
      }
      rethrow;
    }
  }
}