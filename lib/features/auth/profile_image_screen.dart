import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/profile_storage_service.dart';
import '../../services/profile_service.dart';
import '../../services/image_picker_service.dart';

import '../../widgets/custom_button.dart';

class ProfileImageScreen extends StatefulWidget {
  const ProfileImageScreen({super.key});

  @override
  State<ProfileImageScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileImageScreen> {
  File? image;
  final profileService = ProfileService(ProfileStorageService());

  bool isLoading = false;

  Future<void> pickImage() async {
    if (isLoading) return; // ← 念のためガード

    try {
      final pickedImage = await ImagePickerService().pickImage();

      if (pickedImage == null) return;
      if (!mounted) return;

      setState(() {
        image = pickedImage;
      });
    } catch (e) {
      debugPrint("フォトライブラリから画像の取得に失敗しました。$e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("画像の取得に失敗しました")),
      );
    }
  }

  Future<void> saveProfileImage() async {
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("プロフィール画像を選択してください。")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await profileService.saveProfileImage(image!);

      if (!mounted) return;
      context.go('/search');
    } catch (e) {
      debugPrint("プロフィール画像の保存に失敗しました。$e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("保存に失敗しました")),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),

                      const Text(
                        "プロフィール画像を登録",
                        style: TextStyle(fontSize: 20),
                      ),

                      const SizedBox(height: 50),

                      // プロフィール画像
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.black,
                          backgroundImage:
                              image != null ? FileImage(image!) : null,
                          child: image == null
                              ? const Icon(Icons.person,
                                  size: 40, color: Colors.white)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 120),

                      CustomButton(
                        text: "画像を選択",
                        onPressed: isLoading ? null : pickImage,
                      ),

                      const SizedBox(height: 20),

                      CustomButton(
                        text: isLoading ? "保存中..." : "プロフィール画像に設定",
                        onPressed: isLoading ? null : saveProfileImage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔥 ローディング中は画面全体ロック
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}