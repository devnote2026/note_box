import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/image_picker_service.dart';
import '../../services/user_service.dart';
import '../../services/profile_storage_service.dart';

import '../../widgets/profile_image_picker.dart';
import '../../widgets/nickname_field.dart';
import '../../widgets/grade_dropdown.dart';
import '../../widgets/department_dropdown.dart';
import '../../widgets/custom_button.dart';

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

  Future<void> _onUpdate() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      _show("ニックネームを入力してください");
      return;
    }
    if (selectedGrade == null) {
      _show("学年を選択してください");
      return;
    }
    if (selectedDepartment == null) {
      _show("学科を選択してください");
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      String? imageUrl = widget.currentImageUrl;

      if (selectedImage != null) {
        imageUrl = await _storageService.uploadProfileImage(
          uid,
          selectedImage!,
        );
      }

      await _userService.updateUserProfile(
        uid: uid,
        nickname: nickname,
        grade: selectedGrade,
        department: selectedDepartment,
        profileImageUrl: imageUrl,
      );

      if (!mounted) return;

      _show("プロフィールを更新しました");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _show("更新に失敗しました");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("プロフィール編集"),
        backgroundColor: Colors.white,
      ),

      /// 🔥 SafeArea追加
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + bottomInset, // 👈 キーボード対応
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileImagePicker(
                imageUrl: widget.currentImageUrl,
                imageFile: selectedImage,
                onTap: _onTapImage,
              ),

              const SizedBox(height: 24),

              NicknameField(
                controller: _nicknameController,
              ),

              const SizedBox(height: 16),

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

              CustomButton(
                text: isLoading ? "更新中..." : "更新する",
                onPressed: _onUpdate,
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}