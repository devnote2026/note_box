import 'dart:io';

import './storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


//① ユーザーのプロフィールを取得する
//② プロフィール画像をストレージにアップロードし、URL、初回登録進捗状況更新

class ProfileService {
  final StorageService storageService;

  ProfileService(this.storageService);

  
  Future<Map<String,dynamic>> getProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance  
                                 .collection("users")
                                 .doc(uid)
                                 .get();
    
    return doc.data()!;
  }




  Future<void> saveProfileImage (File image) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final url = await storageService.uploadProfileImage(uid, image);

    await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .update({
              "profileImageUrl": url,
              "isProfileCompleted": true
            }
            );
  }
}