// ログインまわりの処理をまとめる

//① Googleサインイン処理
//② Googleサインアウト処理 
//③ ログイン状態が変化したかを通知する処理

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/material.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  

  //Googleサインイン処理
  Future <UserCredential?> signInWithGoogle() async {

    try{
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      
      await googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =  googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken
      );

      return await _auth.signInWithCredential(credential);
    }
    
    //Googleサインインに失敗したら処理を終了
    catch(e){
      debugPrint("Googleサインインに失敗: $e");
      return null;
    }
  }


  //サインアウト処理
  Future<void> signOut() async {
    try{
      await GoogleSignIn.instance.signOut();
      await _auth.signOut;
    }
    catch(e){
      debugPrint("サインアウトエラー: $e");
      return;
    }
  }

  //ログイン状態の変化を通知する
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}