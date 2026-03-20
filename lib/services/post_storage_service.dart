import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/image_utils.dart';
import 'package:flutter/foundation.dart';

//投稿用の画像をアップロードする処理

class PostStorageService {
  final _storage = FirebaseStorage.instance;

  /// 投稿画像アップロード
  Future<String> uploadPostImage({    //画像、noteId、postIdを受け取る
    required File image,
    required String noteId,
    required String postId,
  }) async {
    try {
      final converted = await ImageUtils.convertToJpg(image);  //Jpegに変換。

      final ref = _storage                 //posts/noteIdに保存
          .ref()
          .child("posts")
          .child(noteId)
          .child("$postId.jpg");

      await ref.putFile(
        converted,
        SettableMetadata(contentType: "image/jpeg"),
      );

      return await ref.getDownloadURL();         //保存先のURLを返す
    } catch (e) {
      debugPrint("投稿画像アップロード失敗: $e");
      rethrow;
    }
  }

  /// 投稿画像削除
  Future<void> deletePostImage(String url) async {  //投稿に失敗した時に画像を削除する
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint("投稿画像削除失敗: $e");
    }
  }
}