import 'package:flutter/material.dart';

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
    final text = "${grade ?? ""}  ${department ?? ""}";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// 🔥 テキストは必ずExpanded
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 8),

        /// 🔥 アイコンは固定（潰れない）
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: onTapSettings,
        ),
      ],
    );
  }
}