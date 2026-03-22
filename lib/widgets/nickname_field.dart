// widgets/nickname_field.dart
import 'package:flutter/material.dart';

class NicknameField extends StatelessWidget {
  final TextEditingController controller;

  const NicknameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "ニックネーム",
        border: OutlineInputBorder(),
      ),
    );
  }
}