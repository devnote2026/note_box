// ユーザー情報の保存・取得を行う処理をまとめる。

// ①ニックネームを保存するタイミングでユーザーの情報を保存する。

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _db = FirebaseFirestore.instance;


  //初回ログイン時(ニックネームを保存するタイミング)でユーザーのuidとニックネームを保存する。
  Future<void> createUser({

    required String uid,
    required String nickname

  }) async {

    await _db.collection('users')
             .doc(uid)
             .set({
              "uid": uid,
              "nickname": nickname,
              "grade":null,
              "department": null,
              "profileImageUrl": null,
              "createAt": FieldValue.serverTimestamp(),
              "isProfileCompleted": false
             }
             );

  }
}
