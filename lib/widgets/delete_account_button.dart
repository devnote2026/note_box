import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../widgets/delete_account_dialog.dart';

class DeleteAccountButton extends StatefulWidget {
  const DeleteAccountButton({super.key});

  @override
  State<DeleteAccountButton> createState() => _DeleteAccountButtonState();
}

class _DeleteAccountButtonState extends State<DeleteAccountButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // =========================
        // 🔘 削除ボタン
        // =========================
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading
              ? null // ローディング中は押せない
              : () async {
                  final shouldDelete =
                      await showDeleteAccountDialog(context);
                  if (shouldDelete != true) return;

                  setState(() => _isLoading = true);

                  print("🔥 削除処理スタート");

                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ログイン状態が切れています')),
                    );
                    setState(() => _isLoading = false);
                    return;
                  }

                  try {
                    final token = await user.getIdToken(true);
                    if (token != null) {
                      print("🔑 トークン取得成功");
                    }
                  } catch (e) {
                    print("💥 トークン取得失敗: $e");
                  }

                  try {
                    final functions = FirebaseFunctions.instanceFor(
                      region: 'us-central1',
                    );

                    final callable =
                        functions.httpsCallable('deleteUserData');

                    final result = await callable.call();

                    print("✅ 成功: ${result.data}");

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('アカウントを削除しました')),
                    );

                    context.go('/login');
                  } on FirebaseFunctionsException catch (e) {
                    print("💥 Functionsエラー: ${e.message}");

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('アカウントを削除できませんでした')),
                    );
                  } catch (e) {
                    print("💥 不明エラー: $e");

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('削除失敗: $e')),
                    );
                  } finally {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
          child: const Text(
            'アカウント削除',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // =========================
        // 🚫 画面ブロック（これが連打防止）
        // =========================
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}