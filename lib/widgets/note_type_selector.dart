import 'package:flutter/material.dart';
import '../constants/note_type.dart';

class NoteTypeSelector extends StatelessWidget {
  final Function(String) onChanged;
  final String selected;

  const NoteTypeSelector({
    super.key,
    required this.onChanged,
    required this.selected,
  });

  /// 内部値（キー）
  static const List<String> values = [
    NoteType.lesson,
    NoteType.pastExam,
    NoteType.practice,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: values.map((value) {
          final isSelected = value == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                /// 🔥 状態は持たない
                onChanged(value);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    NoteType.displayMap[value]!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}