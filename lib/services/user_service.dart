import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  /// ログイン直後にユーザーを作成（存在しなければ）
  Future<void> createUserIfNotExists(User user) async {
    final doc = await _db.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      await _db.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "email": user.email,
        "nickname": null,
        "grade": null,
        "department": null,
        "profileImageUrl": null,
        "createdAt": FieldValue.serverTimestamp(),
        "gradeDepartmentSaved": false,
        "isProfileCompleted": false,
        "receivedLabelCount": 0,
        "agreedToTerms": false,
        "termsVersion": null,
        "agreedAt": null,
      });
    }
  }

  /// 学年・学科保存
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
      debugPrint("学科・学年の保存に失敗しました: $e");
      rethrow;
    }
  }

  /// プロフィール更新（nickname / 画像など全部ここ）
  Future<void> updateUserProfile({
    required String uid,
    String? nickname,
    String? grade,
    String? department,
    String? profileImageUrl,
  }) async {
    try {
      final doc = await _db.collection("users").doc(uid).get();
      final data = doc.data();

      final Map<String, dynamic> updateData = {
        "updatedAt": FieldValue.serverTimestamp(),
      };

      if (nickname != null) updateData["nickname"] = nickname;
      if (grade != null) updateData["grade"] = grade;
      if (department != null) updateData["department"] = department;
      if (profileImageUrl != null) {
        updateData["profileImageUrl"] = profileImageUrl;
      }

      // 学年・学科フラグ
      if (
        (grade ?? data?["grade"]) != null &&
        (department ?? data?["department"]) != null
      ) {
        updateData["gradeDepartmentSaved"] = true;
      }

      // プロフィール完成フラグ
      if (
        (nickname ?? data?["nickname"]) != null &&
        (grade ?? data?["grade"]) != null &&
        (department ?? data?["department"]) != null &&
        (profileImageUrl ?? data?["profileImageUrl"]) != null
      ) {
        updateData["isProfileCompleted"] = true;
      }

      await _db.collection("users").doc(uid).update(updateData);
    } catch (e) {
      debugPrint("プロフィール更新に失敗しました: $e");
      rethrow;
    }
  }

  /// 利用規約・プライバシーポリシー同意
Future<void> agreeToTerms({
  required String uid,
  required String termsVersion,
}) async {
  try {
    await _db.collection("users").doc(uid).update({
      "agreedToTerms": true,
      "agreedAt": FieldValue.serverTimestamp(),
      "termsVersion": termsVersion,
    });
  } catch (e) {
    debugPrint("規約同意の保存に失敗しました: $e");
    rethrow;
  }
}
}