import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {

  static Future<File> convertToJpg(File file) async {
    try {

      /// 🔥 元サイズ取得
      final originalSize = await file.length(); // bytes
      final originalKB = originalSize / 1024;

      final dir = await getTemporaryDirectory();

      final targetPath =
          "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        format: CompressFormat.jpeg,
        quality: 70, // 👈 ここが超重要（今90 → 70に下げる）
      );

      if (result == null) {
        throw Exception("JPEG化に失敗しました。");
      }

      final compressedFile = File(result.path);

      /// 🔥 圧縮後サイズ
      final compressedSize = await compressedFile.length();
      final compressedKB = compressedSize / 1024;

      /// 🔥 圧縮率
      final reduction =
          ((originalSize - compressedSize) / originalSize) * 100;

      debugPrint("📸 元サイズ: ${originalKB.toStringAsFixed(1)} KB");
      debugPrint("📦 圧縮後: ${compressedKB.toStringAsFixed(1)} KB");
      debugPrint("🔥 削減率: ${reduction.toStringAsFixed(1)} %");

      return compressedFile;

    } catch (e) {
      debugPrint("画像圧縮エラー: $e");
      rethrow;
    }
  }
}