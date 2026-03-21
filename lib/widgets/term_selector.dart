import 'package:flutter/material.dart';

class TermSelector extends StatelessWidget {
  final List<String> terms;
  final String? selectedTerm;
  final Function(String) onSelected;
  final bool enabled;

  const TermSelector({
    super.key,
    required this.terms,
    required this.selectedTerm,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
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
                  elevation: enabled ? 2 : 0,
                  side: BorderSide(
                    color: enabled ? Colors.black : Colors.grey,
                  ),
                  backgroundColor: enabled
                      ? (isSelected ? Colors.black : Colors.white)
                      : Colors.grey[200],
                ),
                onPressed: enabled
                    ? () {
                        onSelected(term);
                      }
                    : null,
                child: Text(
                  term,
                  style: TextStyle(
                    color: enabled
                        ? (isSelected ? Colors.white : Colors.black)
                        : Colors.grey,
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