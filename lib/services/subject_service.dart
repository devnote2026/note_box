import 'package:cloud_firestore/cloud_firestore.dart';

//学年・学科から教科リストを取得する

class SubjectService {

  Future<List<String>> getSubjects (String grade, String department) async {

    final docId = '${grade}_$department';

    final doc = await FirebaseFirestore.instance
                                       .collection("subjects")
                                       .doc(docId)
                                       .get();
    
    final data = doc.data();

    if(data == null) return [];

    return List<String>.from(data['list']);
  }
}

