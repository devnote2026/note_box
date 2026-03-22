import 'package:flutter/material.dart';

class StatsToggle extends StatelessWidget {
  final bool isMonthly;
  final ValueChanged<bool> onChanged;

  const StatsToggle({
    super.key,
    required this.isMonthly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('月間'),
          selected: isMonthly,
          onSelected: (_) => onChanged(true),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('全期間'),
          selected: !isMonthly,
          onSelected: (_) => onChanged(false),
        ),
      ],
    );
  }
}