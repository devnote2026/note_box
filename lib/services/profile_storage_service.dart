import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/image_utils.dart';

import 'package:flutter/foundation.dart';

//①プロフィール画像を JPEG形式に変換してからストレージにアップロードする関数

class ProfileStorageService {
  final _storage = FirebaseStorage.instance;
  
Future<String> uploadProfileImage(String uid, File image) async {
  try {

    final converted = await ImageUtils.convertToJpg(image);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final folderRef = _storage.ref().child("users").child(uid);

    // 古い画像削除
    final list = await folderRef.listAll();
    for (final item in list.items) {
      await item.delete();
    }

    final ref = folderRef.child("profile_$timestamp.jpg");

    await ref.putFile(
      converted,
      SettableMetadata(contentType: "image/jpeg"),
    );

    return await ref.getDownloadURL();

  } catch (e) {
    debugPrint("プロフィール画像のアップロードに失敗しました。$e");
    rethrow;
  }
}
}