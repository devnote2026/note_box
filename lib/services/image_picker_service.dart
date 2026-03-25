import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
    try {
      // 🔐 権限チェック（Android）
      if (Platform.isAndroid) {
        PermissionStatus status;

        // Android13以上
        if (await Permission.photos.isGranted) {
          status = PermissionStatus.granted;
        } else {
          status = await Permission.photos.request();
        }

        // Android12以下のフォールバック
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        // ❌ 拒否された場合
        if (status.isDenied) {
          throw Exception("ギャラリーへのアクセスが拒否されました");
        }

        // ❌ 永久拒否（←重要）
        if (status.isPermanentlyDenied) {
          await openAppSettings();
          throw Exception("設定から写真アクセスを許可してください");
        }
      }

      // 📸 画像取得
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85, // 🔥 軽量化（実務ではほぼ必須）
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);

    } catch (e) {
      throw Exception("画像取得エラー: $e");
    }
  }
}