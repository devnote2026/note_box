import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  final bool isMonthly;

  const StatsGrid({super.key, required this.isMonthly});

  @override
  Widget build(BuildContext context) {
    // 仮データ
    final stats = isMonthly
        ? {'いいね': 12, '閲覧数': 340, '投稿数': 5}
        : {'いいね': 120, '閲覧数': 4300, '投稿数': 42};

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: stats.entries.map((e) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  e.value.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(e.key),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}