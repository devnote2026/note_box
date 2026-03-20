import 'package:flutter/material.dart';
import '../constants/note_type.dart';

class NoteTypeSelector extends StatefulWidget {
  final Function(String) onChanged;
  final String initialValue;

  const NoteTypeSelector({
    super.key,
    required this.onChanged,
    required this.initialValue,
  });

  @override
  State<NoteTypeSelector> createState() => _SegmentControlState();
}

class _SegmentControlState extends State<NoteTypeSelector> {
  late String selected;

  /// 🔥 内部値（正しいキー）
  final List<String> values = [
    NoteType.lesson,
    NoteType.pastExam,
    NoteType.practice,
  ];

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

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
                setState(() {
                  selected = value;
                });

                /// 🔥 親には「英語キー」を返す
                widget.onChanged(value);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    /// 🔥 表示は日本語
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