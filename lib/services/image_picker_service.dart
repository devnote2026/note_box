import 'dart:io';
import 'package:image_picker/image_picker.dart';

//画像容量最大800で写真ギャラリーから画像を返す。

class ImagePickerService {

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      throw Exception("画像取得エラー: $e");
    }
  }
}