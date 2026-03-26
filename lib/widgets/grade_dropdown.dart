import 'package:flutter/material.dart';

class GradeDropdown extends StatelessWidget {
  final String? value;
  final List<String> grades;
  final ValueChanged<String?> onChanged;

  const GradeDropdown({
    super.key,
    required this.value,
    required this.grades,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true, // 🔥 これ超重要（横overflow防止）

      value: grades.contains(value) ? value : null,

      decoration: const InputDecoration(
        labelText: "学年",
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ), // 🔥 高さ確保
      ),

      items: grades.map((grade) {
        return DropdownMenuItem<String>(
          value: grade,

          /// 🔥 ここも重要（中の文字のoverflow対策）
          child: Text(
            grade,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}