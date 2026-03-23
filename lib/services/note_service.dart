import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/foundation.dart";


/// 🔍 ノート検索
Future<List<QueryDocumentSnapshot>> fetchNotes({
  String? grade,
  String? department,
  String? subject,
  String? noteType,
  String? term,
}) async {
  Query query = FirebaseFirestore.instance.collection('notes');

  if (grade != null) {
    query = query.where('grade', isEqualTo: grade);
  }
  if (department != null) {
    query = query.where('department', isEqualTo: department);
  }
  if (subject != null) {
    query = query.where('subject', isEqualTo: subject);
  }
  if (noteType != null) {
    query = query.where('noteType', isEqualTo: noteType);
  }
  if (term != null) {
    query = query.where('term', isEqualTo: term);
  }

  final snapshot = await query
      .orderBy('updatedAt', descending: true)
      .limit(20)
      .get();

  return snapshot.docs;
}

/// 🗑 投稿削除 + Storage削除 + ノート削除（完全版）
Future<bool> deletePost({
  required String noteId,
  required String postId,
}) async {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final noteRef = firestore.collection('notes').doc(noteId);
  final postRef = noteRef.collection('posts').doc(postId);

  try {
    /// 🔥 ① 画像URL取得（削除前に！）
    final postSnap = await postRef.get();
    final data = postSnap.data();
    final imageUrl = data?['imageUrl'];

    /// 🔥 ② Firestoreトランザクション
    final isNoteDeleted = await firestore.runTransaction<bool>((tx) async {
      final noteSnap = await tx.get(noteRef);

      if (!noteSnap.exists) return false;

      /// 投稿削除
      tx.delete(postRef);

      /// postCount減らす
      tx.update(noteRef, {
        'postCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      /// 残りチェック（軽量）
      final remaining = await noteRef.collection('posts').limit(1).get();

      if (remaining.docs.length <= 1) {
        /// 最後の1件だった場合 → ノート削除
        tx.delete(noteRef);
        return true;
      }

      return false;
    });

    /// 🔥 ③ Storage削除（トランザクション外）
    if (imageUrl != null) {
      try {
        await storage.refFromURL(imageUrl).delete();
      } catch (e) {
        debugPrint("Storage削除失敗: $e");
      }
    }

    return isNoteDeleted;

  } catch (e) {
    debugPrint("削除エラー: $e");
    return false;
  }
}