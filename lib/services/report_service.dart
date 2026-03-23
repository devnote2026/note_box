import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  static Future<bool> reportPost({
    required String noteId,
    required String postId,
    required String userId,
  }) async {
    try {
      final reportId = "${postId}_$userId";

      final docRef = FirebaseFirestore.instance
          .collection("reports")
          .doc(reportId);

      final doc = await docRef.get();

      // すでに通報済みかチェック
      if (doc.exists) {
        return false;
      }

      await docRef.set({
        'noteId': noteId,
        'postId': postId,
        'reportedBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}