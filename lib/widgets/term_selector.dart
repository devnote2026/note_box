import 'package:flutter/material.dart';

// 時期を選択する

class TermSelector extends StatefulWidget {
  final Function(String) onTermSelected;
  final String? initialValue;
  final bool enabled; // 有効にする

  const TermSelector({
    super.key,
    required this.onTermSelected,
    this.initialValue,
    this.enabled = true,
  });

  @override
  State<TermSelector> createState() => _TermSelectorState();
}

class _TermSelectorState extends State<TermSelector> {
  final List<String> terms = [
    '前期中間',
    '前期末',
    '後期中間',
    '学年末',
  ];

  String? selectedTerm;

  @override
  void initState() {
    super.initState();
    selectedTerm = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant TermSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      selectedTerm = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5, // 👈 無効時ちょい薄く
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: terms.map((term) {
            final isSelected = term == selectedTerm;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: widget.enabled ? 2 : 0, // 👈 無効時フラット
                  side: BorderSide(
                    color: widget.enabled ? Colors.black : Colors.grey,
                  ),
                  backgroundColor: widget.enabled
                      ? (isSelected ? Colors.black : Colors.white)
                      : Colors.grey[200], // 👈 無効背景
                ),
                onPressed: widget.enabled
                    ? () {
                        setState(() {
                          selectedTerm = term;
                        });

                        widget.onTermSelected(term);
                      }
                    : null,
                child: Text(
                  term,
                  style: TextStyle(
                    color: widget.enabled
                        ? (isSelected ? Colors.white : Colors.black)
                        : Colors.grey, // 👈 無効文字
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}