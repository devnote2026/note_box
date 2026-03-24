import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../widgets/delete_account_dialog.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () async {
        final shouldDelete = await showDeleteAccountDialog(context);
        if (shouldDelete != true) return;

        print("🔥 削除処理スタート");

        // =========================
        // 🔍 ① Auth状態チェック
        // =========================
        final user = FirebaseAuth.instance.currentUser;

        print("👤 currentUser: $user");
        print("🆔 uid: ${user?.uid}");
        print("📦 projectId: ${FirebaseAuth.instance.app.options.projectId}");

        if (user == null) {
          print("❌ ユーザーがnull → 未ログイン状態");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ログイン状態が切れています')),
          );
          return;
        }

        // =========================
        // 🔍 ② トークン取得チェック
        // =========================
        try {
          final token = await user.getIdToken(true);
          if(token != null){
            print("🔑 IDトークン取得成功: ${token.substring(0, 20)}...");
          }else{
            print("❌ トークンがnull");
          }
        } catch (e) {
          print("💥 トークン取得失敗: $e");
        }

        try {
          // =========================
          // 🔍 ③ Functionsリージョン指定
          // =========================
          final functions = FirebaseFunctions.instanceFor(
            region: 'us-central1', 
          );

          final callable = functions.httpsCallable('deleteUserData');

          print("📡 Cloud Functions呼び出し開始");

          final result = await callable.call();

          print("✅ 成功: ${result.data}");

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('アカウントを削除しました')),
          );

          context.go('/login');

        } on FirebaseFunctionsException catch (e) {
          print("💥 Functionsエラー");
          print("code: ${e.code}");
          print("message: ${e.message}");
          print("details: ${e.details}");

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '削除失敗\n${e.code}\n${e.message}',
              ),
            ),
          );

        } catch (e, stack) {
          print("💥 不明なエラー: $e");
          print("📍 stack: $stack");

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除失敗: $e')),
          );
        }
      },
      child: const Text(
        'アカウント削除',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}