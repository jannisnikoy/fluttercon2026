import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/colors.dart';
import 'package:fluttercon2026/_utils/data/schedule_controller.dart';
import 'package:fluttercon2026/_utils/data/models.dart';
import 'package:fluttercon2026/_utils/theme.dart';
import 'package:fluttercon2026/_utils/widgets/avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final Speaker? speaker;
  final VoidCallback onTap;

  const SessionCard({super.key, required this.session, required this.speaker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final schedule = context.watch<ScheduleController>();
    final bookmarked = schedule.isBookmarked(session.id);

    final accent = Color(session.accentColor);
    final metaParts = <String>[
      if (session.room.isNotEmpty) session.room,
      if (session.typeLabel != null)
        session.typeLabel!
      else if (session.track != null)
        displayTrackLabel(session.track!),
    ];
    final meta = metaParts.join(' • ');

    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${DateFormat('HH:mm a').format(session.start)} - ${DateFormat('HH:mm a').format(session.end)}',
              style: AppTheme.heading(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.mutedForeground,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: accent),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          meta,
                                          style: AppTheme.heading(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: accent,
                                            letterSpacing: 0.8,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => schedule.toggleBookmark(session.id),
                                  child: Icon(
                                    bookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    size: 18,
                                    color: bookmarked ? AppColors.primary : AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              session.title,
                              style: AppTheme.body(fontSize: 16, fontWeight: FontWeight.w600, height: 1.25),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (speaker != null) ...[
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  context.push('/speakers/${speaker!.id}', extra: speaker);
                                },
                                child: Row(
                                  children: [
                                    GrayscaleAvatar(url: speaker!.imageUrl, size: 24),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        speaker!.name,
                                        style: AppTheme.body(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
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
}

class BreakCard extends StatelessWidget {
  const BreakCard({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '${DateFormat('HH:mm a').format(session.start)} - ${DateFormat('HH:mm a').format(session.end)}',
            style: AppTheme.heading(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.mutedForeground,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.coffee, size: 16, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Text(
                      session.title.toUpperCase(),
                      style: AppTheme.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedForeground,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                if (session.breakLocation != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      session.breakLocation!,
                      style: AppTheme.body(fontSize: 10, color: AppColors.mutedForeground.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
