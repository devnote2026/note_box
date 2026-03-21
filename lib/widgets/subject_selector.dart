import 'package:flutter/material.dart';

class SubjectSelector extends StatelessWidget {
  final List<String> subjects;
  final String? selectedSubject;
  final Function(String) onSelect;
  final bool isLoading;
  final String? errorText;

  const SubjectSelector({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSelect,
    this.isLoading = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    // 🔄 ローディング
    if (isLoading) {
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ❌ エラー or 空
    if (subjects.isEmpty) {
      return Center(
        child: Text(errorText ?? "教科がありません"),
      );
    }

    // ✅ データあり（← SubjectsListのデザイン採用）
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: subjects.map((subject) {
          final isSelected = subject == selectedSubject;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                backgroundColor:
                    isSelected ? Colors.black : Colors.white,
              ),
              onPressed: () {
                onSelect(subject);
              },
              child: Text(
                subject,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}