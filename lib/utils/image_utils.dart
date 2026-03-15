import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {

  static Future<File> convertToJpg(File file) async {

    try {

      final dir = await getTemporaryDirectory();

      final targetPath =
          "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        format: CompressFormat.jpeg,
        quality: 90,
      );

      if (result == null) {
        throw Exception("JPEG化に失敗しました。");
      }

      return File(result.path);

    } catch (e) {
      debugPrint("画像をJPEG形式に変換できませんでした。: $e");
      rethrow;
    }
  }
}