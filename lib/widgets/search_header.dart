import 'package:flutter/material.dart';

//検索画面上部で学年、学科、設定アイコンを表示するウィジェット。

class SearchHeader extends StatelessWidget {
  final String? grade;
  final String? department;
  final VoidCallback onTapSettings;

  const SearchHeader({
    super.key,
    required this.grade,
    required this.department,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$grade  $department",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: onTapSettings,
        ),
      ],
    );
  }
}