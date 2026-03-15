// ユーザー情報の保存・取得を行う処理をまとめる。

// ①ニックネームを保存するタイミングでユーザーの情報を保存する。
// ②学年・学科を選択したタイミングでデータを更新する。

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
              "createdAt": FieldValue.serverTimestamp(),
              "gradeDepartmentSaved": false,
              "isProfileCompleted": false
             }
             );

  }


  // 学年・学科が選択された時に更新する。
  Future<void> saveGradeDepartment ({

    required String uid,
    required String grade,
    required String department

  }) async{
    try{
      await _db.collection("users")
               .doc(uid)
               .update({
                "grade": grade,
                "department": department,
                "gradeDepartmentSaved": true,
                "updatedAt": FieldValue.serverTimestamp(),
               });
    }

    catch(e){
      debugPrint("学科・学年の保存に失敗しました。: $e");
      rethrow;
    }
  }
}
