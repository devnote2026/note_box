import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/image_utils.dart';

import 'package:flutter/foundation.dart';

//①プロフィール画像を JPEG形式に変換してからストレージにアップロードする関数

class StorageService {
  final _storage = FirebaseStorage.instance;
  


  // 画像をアップロードする関数
  Future<String> uploadProfileImage (String uid, File image) async {
    try{

      final converted = await ImageUtils.convertToJpg(image);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final ref = _storage
                  .ref()
                  .child("users")
                  .child(uid)
                  .child("profile_$timestamp.jpg");

      await ref.putFile(converted);

      return await ref.getDownloadURL();
      
      }

    catch(e){
      debugPrint("プロフィール画像のアップロードに失敗しました。$e");
      rethrow;
    }
  }
}