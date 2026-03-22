import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/image_picker_service.dart';
import '../../services/user_service.dart';
import '../../services/profile_storage_service.dart';

// widgets
import '../../widgets/profile_image_picker.dart';
import '../../widgets/nickname_field.dart';
import '../../widgets/grade_dropdown.dart';
import '../../widgets/department_dropdown.dart';
import '../../widgets/custom_button.dart';

// constants
import '../../constants/profile_constants.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentNickname;
  final String? currentGrade;
  final String? currentDepartment;
  final String? currentImageUrl;

  const EditProfileScreen({
    super.key,
    required this.currentNickname,
    this.currentGrade,
    this.currentDepartment,
    this.currentImageUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfileScreen> {
  late TextEditingController _nicknameController;

  String? selectedGrade;
  String? selectedDepartment;

  File? selectedImage;

  final ImagePickerService _imageService = ImagePickerService();
  final UserService _userService = UserService();
  final ProfileStorageService _storageService = ProfileStorageService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _nicknameController =
        TextEditingController(text: widget.currentNickname);

    selectedGrade = grades.contains(widget.currentGrade)
        ? widget.currentGrade
        : null;

    selectedDepartment = departments.contains(widget.currentDepartment)
        ? widget.currentDepartment
        : null;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  /// 📷 画像選択
  Future<void> _onTapImage() async {
    try {
      final file = await _imageService.pickImage();

      if (file != null) {
        setState(() {
          selectedImage = file;
        });
      }
    } catch (e) {
      debugPrint("画像取得エラー: $e");
    }
  }

  /// 🚀 更新処理（完全版）
  Future<void> _onUpdate() async {
    final nickname = _nicknameController.text.trim();

    /// バリデーション
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ニックネームを入力してください")),
      );
      return;
    }

    if (selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("学年を選択してください")),
      );
      return;
    }

    if (selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("学科を選択してください")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      /// 🔥 ① 画像アップロード（変更があれば）
      String? imageUrl = widget.currentImageUrl;

      if (selectedImage != null) {
        imageUrl = await _storageService.uploadProfileImage(
          uid,
          selectedImage!,
        );
      }

      /// 🔥 ② Firestore更新
      await _userService.updateUserProfile(
        uid: uid,
        nickname: nickname,
        grade: selectedGrade,
        department: selectedDepartment,
        profileImageUrl: imageUrl,
      );

      /// 成功
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("プロフィールを更新しました")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("更新エラー: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("更新に失敗しました")),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("プロフィール編集"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔵 プロフィール画像
            ProfileImagePicker(
              imageUrl: widget.currentImageUrl,
              imageFile: selectedImage,
              onTap: _onTapImage,
            ),

            const SizedBox(height: 24),

            /// 📝 ニックネーム
            NicknameField(
              controller: _nicknameController,
            ),

            const SizedBox(height: 16),

            /// 🎓 学年
            GradeDropdown(
              value: selectedGrade,
              grades: grades,
              onChanged: (value) {
                setState(() {
                  selectedGrade = value;
                });
              },
            ),

            const SizedBox(height: 16),

            /// 🏫 学科
            DepartmentDropdown(
              value: selectedDepartment,
              departments: departments,
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
              },
            ),

            const SizedBox(height: 24),

            /// 🚀 更新ボタン
            CustomButton(
              text: "更新する",
              onPressed: _onUpdate,
            ),
          ],
        ),
      ),
    );
  }
}