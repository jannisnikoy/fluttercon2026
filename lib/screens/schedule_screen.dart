import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/colors.dart';
import 'package:fluttercon2026/_utils/data/conference_data.dart';
import 'package:fluttercon2026/_utils/data/schedule_controller.dart';
import 'package:fluttercon2026/_utils/theme.dart';
import 'package:fluttercon2026/_utils/widgets/day_selector.dart';
import 'package:fluttercon2026/_utils/widgets/session_card.dart';
import 'package:fluttercon2026/screens/session_detail_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreen();
}

class _ScheduleScreen extends State<ScheduleScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = ConferenceData.days.first.date;
  }

  @override
  Widget build(BuildContext context) {
    final schedule = context.watch<ScheduleController>();
    final byDay = schedule.bookmarkedByDay;

    final sessions = byDay[_selectedDay] ?? [];

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 116, left: 16, right: 16, bottom: 24),
              itemCount: sessions.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                final session = sessions[index];
                final speaker = session.speakerIds.isEmpty
                    ? null
                    : ConferenceData.speakerById(session.speakerIds.first);
                return session.isBreak
                    ? BreakCard(session: session)
                    : SessionCard(
                        session: session,
                        speaker: speaker,
                        onTap: () {
                          context.push(
                            '/sessions/${session.id}',
                            extra: SessionDetailArgs(
                              session: session,
                              speakers: session.speakerIds.map((e) => ConferenceData.speakerById(e)).toList(),
                            ),
                          );
                        },
                      );
              },
            ),
          ),

          Column(
            children: [
              Container(
                color: AppColors.background,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('MY SCHEDULE', style: AppTheme.heading(fontSize: 20, letterSpacing: -0.3)),
                      ),
                      DaySelector(selected: _selectedDay, onChanged: (d) => setState(() => _selectedDay = d)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
