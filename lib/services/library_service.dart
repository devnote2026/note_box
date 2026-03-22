import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibraryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;   //DB,Authのインスタンス作成
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔥 自分のノート取得（フィルター付き）
  Future<List<QueryDocumentSnapshot>> fetchMyNotes({                 //親から学年・noteTypeを受け取る (null可)
    String? grade,
    String? noteType,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("ログインしていません");      

    Query query = _firestore                                 //uidを使って自分のノートを取得
        .collection('notes')
        .where('uid', isEqualTo: user.uid);

                      
    if (grade != null && grade.isNotEmpty) {                  //grade(学年)が指定されているなら uid,学年が一致するものを取得
      query = query.where('grade', isEqualTo: grade);
    }

    if (noteType != null && noteType.isNotEmpty) {            //noteTypeが指定されているなら uid,noteTypeが一致するものを取得
      query = query.where('noteType', isEqualTo: noteType);
    }

    /// 🔥 並び替え（新しい順）
    query = query.orderBy('updatedAt', descending: true);

    final snapshot = await query.get();
    return snapshot.docs;                        
  }
}