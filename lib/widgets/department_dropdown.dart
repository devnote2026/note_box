import 'package:flutter/material.dart';

class DepartmentDropdown extends StatelessWidget {
  final String? value;
  final List<String> departments;
  final ValueChanged<String?> onChanged;

  const DepartmentDropdown({
    super.key,
    required this.value,
    required this.departments,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true, // 🔥 必須

      value: departments.contains(value) ? value : null,

      decoration: const InputDecoration(
        labelText: "学科",
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ), // 🔥 高さ確保
      ),

      items: departments.map((dept) {
        return DropdownMenuItem<String>(
          value: dept,
          child: Text(
            dept,
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // 🔥 崩れ防止
          ),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}