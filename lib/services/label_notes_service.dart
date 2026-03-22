import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/labeled_note.dart';

//ラベルをしたノートを取得する処理

class LabeledNotesService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// 🔥 初回取得
  Future<List<LabeledNote>> fetchLabeledNotes({int limit = 20}) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception("ログインしていません");
    }

    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('labeledNotes')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LabeledNote.fromDoc(doc))
          .toList();
    } catch (e) {
      throw Exception("ラベルノート取得失敗: $e");
    }
  }

  /// 🔥 ページング用（無限スクロール）
  Future<List<LabeledNote>> fetchMoreLabeledNotes({
    required DocumentSnapshot lastDoc,
    int limit = 20,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception("ログインしていません");
    }

    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('labeledNotes')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LabeledNote.fromDoc(doc))
          .toList();
    } catch (e) {
      throw Exception("追加取得失敗: $e");
    }
  }
}