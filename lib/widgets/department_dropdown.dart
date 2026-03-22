// widgets/department_dropdown.dart
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
      value: departments.contains(value) ? value : null,
      decoration: const InputDecoration(
        labelText: "学科",
        border: OutlineInputBorder(),
      ),
      items: departments.map((dept) {
        return DropdownMenuItem(
          value: dept,
          child: Text(dept),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}