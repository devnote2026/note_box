import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../services/user_service.dart';
import '../../widgets/custom_button.dart';

// ニックネームを入力・保存を行う画面。

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {

  final _nicknameController = TextEditingController();

  bool isLoading = false;   // UI用
  bool _isSaving = false;   // ロジック用（完全ガード）

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // ニックネーム保存（完全連打防止）
Future<void> _saveNickname() async {

  if (_isSaving) return;
  _isSaving = true;

  setState(() {
    isLoading = true;
  });

  try {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ニックネームを入力してください"),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('ユーザーがログインしていません。');
      return;
    }

    // 🔥 Appleログイン対策（超重要）
    if (user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("メールアドレスが取得できません。再ログインしてください"),
        ),
      );
      return;
    }

    await UserService().updateUserProfile(
      uid: user.uid,
      nickname: nickname,
    );

    debugPrint('ニックネームの保存に成功しました: $nickname');

    context.go('/grade_department');

  } catch (e) {
    debugPrint("ニックネームを保存できませんでした $e");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("保存に失敗しました。もう一度試してください"),
      ),
    );
  } finally {
    _isSaving = false;

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "ニックネームを入力してください",
                style: TextStyle(
                  height: 1.5,
                  color: Colors.black,
                ),
              ),

              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '飯間 圭一郎',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              CustomButton(
                text: isLoading ? "保存中..." : "次へ",
                onPressed: isLoading ? null : _saveNickname,
              ),
            ],
          ),
        ),
      ),
    );
  }
}