import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: Colors.red), // 枠線赤
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      onPressed: () async {
        await AuthService().signOut();
      },

      child: const Text(
        'ログアウト',
        style: TextStyle(
          color: Colors.red, // 文字も赤
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}