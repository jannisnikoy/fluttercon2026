import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/colors.dart';
import 'package:fluttercon2026/_utils/data/conference_data.dart';
import 'package:fluttercon2026/_utils/theme.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({super.key, required this.selected, required this.onChanged});

  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border.symmetric(horizontal: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (final day in ConferenceData.days)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(day.date),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: _isSameDay(selected, day.date) ? AppColors.secondary.withValues(alpha: 0.3) : null,
                    border: Border(
                      bottom: BorderSide(
                        color: _isSameDay(selected, day.date) ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day.weekdayShort.toUpperCase(),
                        style: AppTheme.heading(fontSize: 9, color: AppColors.mutedForeground, letterSpacing: 2),
                      ),
                      Text(
                        day.dateLabel,
                        style: AppTheme.heading(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isSameDay(selected, day.date) ? AppColors.foreground : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
