// 検索内容に該当するノート一覧を取得する

//条件を指定して絞り込み、20件取得

import"package:cloud_firestore/cloud_firestore.dart";

Future<List<QueryDocumentSnapshot>> fetchNotes({
  String? grade,
  String? department,
  String? subject,
  String? noteType,
  String? term
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
  if (term != null){
    query = query.where('term', isEqualTo: term);
  }
  final snapshot = await query
      .orderBy('updatedAt', descending: true)
      .limit(20)
      .get();

  return snapshot.docs;
}