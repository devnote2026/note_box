import 'package:flutter/material.dart';

class GradeSelector extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String? selected;
  final List<String> values;

  const GradeSelector({
    super.key,
    required this.onChanged,
    required this.selected,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: values.map((value) {
          final isSelected = value == selected;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                side: const BorderSide(color: Colors.black),
                backgroundColor:
                    isSelected ? Colors.black : Colors.white,
              ),
              onPressed: () {
                onChanged(value);
              },
              child: Text(
                value,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}