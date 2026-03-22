import 'dart:io';

import 'profile_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


//① ユーザーのプロフィールを取得する
//② プロフィール画像をストレージにアップロードし、URL、初回登録進捗状況更新

class ProfileService {
  final ProfileStorageService storageService;

  ProfileService(this.storageService);

  
  Future<Map<String,dynamic>> getProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};


    final doc = await FirebaseFirestore.instance  
                                 .collection("users")
                                 .doc(user.uid)
                                 .get();

    if (doc.data() == null || !doc.exists) return{};
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