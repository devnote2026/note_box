import 'package:flutter/material.dart';
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
        final shouldDelete =
            await showDeleteAccountDialog(context);

        if (shouldDelete == true) {

          //アカウントを削除する処理を後から実装する

          // ✅ 成功メッセージ
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('アカウントを削除しました')),
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