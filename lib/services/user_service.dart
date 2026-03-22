import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ユーザー情報の保存・取得を行う処理をまとめる。
// ①ニックネームを保存するタイミングでユーザーの情報を保存する。
// ②学年・学科を選択したタイミングでデータを更新する。

class UserService {
  final _db = FirebaseFirestore.instance;

  // 初回ログイン時(ニックネームを保存するタイミング)でユーザーのuidとニックネームを保存する。
  Future<void> createUser({
    required String uid,
    required String nickname,
  }) async {
    await _db.collection('users').doc(uid).set({
      "uid": uid,
      "nickname": nickname,
      "grade": null,
      "department": null,
      "profileImageUrl": null,
      "createdAt": FieldValue.serverTimestamp(),
      "gradeDepartmentSaved": false,
      "isProfileCompleted": false,
      "receivedLabelCount": 0,
    }, SetOptions(merge: true));
  }

  // 学年・学科が選択された時に更新する。
  Future<void> saveGradeDepartment({
    required String uid,
    required String grade,
    required String department,
  }) async {
    try {
      await _db.collection("users").doc(uid).update({
        "grade": grade,
        "department": department,
        "gradeDepartmentSaved": true,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("学科・学年の保存に失敗しました。: $e");
      rethrow;
    }
  }

  Future<void> updateUserProfile({      //プロフィールを更新する処理
    required String uid,                //uid,ニックネーム、学年、学科、プロフィール画像のURLを取得する
    String? nickname,
    String? grade,
    String? department,
    String? profileImageUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = {    //更新時の時刻を取得
        "updatedAt": FieldValue.serverTimestamp(),
      };

      if (nickname != null) {                
        updateData["nickname"] = nickname;
      }

      if (grade != null) {
        updateData["grade"] = grade;
      }

      if (department != null) {
        updateData["department"] = department;
      }

      if (profileImageUrl != null) {
        updateData["profileImageUrl"] = profileImageUrl;
      }

      // 学年・学科が両方入ってたらフラグON
      if (grade != null && department != null) {
        updateData["gradeDepartmentSaved"] = true;
      }

      // プロフィール完成判定（必要なら）
      if (nickname != null &&
          grade != null &&
          department != null &&
          profileImageUrl != null) {
        updateData["isProfileCompleted"] = true;
      }

      await _db.collection("users").doc(uid).update(updateData);
    } catch (e) {
      debugPrint("プロフィール更新に失敗しました: $e");
      rethrow;
    }
  }
}