// 様々なファイル形式の画像を jpeg に変換する関数を定義。

import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:flutter/foundation.dart';

class ImageUtils {

  static Future<File> convertToJpg (File file) async {
    
    try{

      final targetPath = file.path.replaceAll(RegExp(r'\.\w+$'), ".jpg");

      final result = await FlutterImageCompress
                          .compressAndGetFile(
                            file.absolute.path,
                            targetPath,
                            format: CompressFormat.jpeg,
                            quality: 90
                            );
      
      if(result == null) {
        throw Exception("JPEG化に失敗しました。");
      }

      return File(result.path);

    }

    catch(e){
      debugPrint("画像をJPEG形式に変換できませんでした。: $e");
      rethrow;
    }
  }
}