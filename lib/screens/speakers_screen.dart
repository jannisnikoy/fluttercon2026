import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/colors.dart';
import 'package:fluttercon2026/_utils/data/conference_data.dart';
import 'package:fluttercon2026/_utils/theme.dart';
import 'package:fluttercon2026/_utils/widgets/speaker_card.dart';
import 'package:go_router/go_router.dart';

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({super.key});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreen();
}

class _SpeakersScreen extends State<SpeakersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 61, left: 16, right: 16, bottom: 24),
              itemCount: ConferenceData.speakers.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                final speaker = ConferenceData.speakers[index];

                return SpeakerCard(
                  speaker: speaker,
                  onTap: () {
                    context.push('/speakers/${speaker.id}', extra: speaker);
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
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('SPEAKERS', style: AppTheme.heading(fontSize: 20, letterSpacing: -0.3)),
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
