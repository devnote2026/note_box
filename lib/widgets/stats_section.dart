import 'package:flutter/material.dart';
import './stats_toggle.dart';
import './stats_grid.dart';

class StatsSection extends StatefulWidget {
  const StatsSection({super.key});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  bool isMonthly = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatsToggle(
          isMonthly: isMonthly,
          onChanged: (value) {
            setState(() => isMonthly = value);
          },
        ),
        const SizedBox(height: 12),
        StatsGrid(isMonthly: isMonthly),
      ],
    );
  }
}