// widgets/grade_dropdown.dart
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
      value: grades.contains(value) ? value : null,
      decoration: const InputDecoration(
        labelText: "学年",
        border: OutlineInputBorder(),
      ),
      items: grades.map((grade) {
        return DropdownMenuItem(
          value: grade,
          child: Text(grade),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}