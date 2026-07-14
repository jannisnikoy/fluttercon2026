import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/colors.dart';
import 'package:fluttercon2026/_utils/theme.dart';

class TrackChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TrackChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(100),
          border: selected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTheme.heading(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primaryForeground : AppColors.secondaryForeground,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
