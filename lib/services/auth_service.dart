import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

import 'user_service.dart'; // ←追加

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Googleサインイン処理
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      final GoogleSignInAccount googleUser =
          await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      // 🔥 ここが今回の本質
      if (user != null) {
        await UserService().createUserIfNotExists(user);
      }

      return userCredential;
    } catch (e) {
      debugPrint("Googleサインインに失敗: $e");
      return null;
    }
  }

  // サインアウト処理
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("サインアウトエラー: $e");
    }
  }

  // ログイン状態の変化を通知
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}