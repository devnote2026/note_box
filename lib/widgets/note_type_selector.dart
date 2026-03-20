import 'package:flutter/material.dart';


// ノートの種類を選択するウィジェット

class NoteTypeSelector extends StatefulWidget {
  final Function(String) onChanged; // 親に返す
  final String initialValue;

  const NoteTypeSelector({
    super.key,
    required this.onChanged,
    this.initialValue = '授業ノート',
  });

  @override
  State<NoteTypeSelector> createState() => _SegmentControlState();
}

class _SegmentControlState extends State<NoteTypeSelector> {
  late String selected;

  final List<String> items = ['授業ノート', '過去問', '演習'];

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
        children: items.map((item) {
          final isSelected = item == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selected = item;
                });
                widget.onChanged(item); // 👈 親に通知
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item,
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