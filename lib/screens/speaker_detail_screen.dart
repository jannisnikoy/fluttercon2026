import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttercon2026/_utils/colors.dart';
import 'package:fluttercon2026/_utils/data/conference_data.dart';
import 'package:fluttercon2026/_utils/data/models.dart';
import 'package:fluttercon2026/_utils/theme.dart';
import 'package:fluttercon2026/_utils/widgets/session_card.dart';
import 'package:fluttercon2026/screens/session_detail_screen.dart';
import 'package:go_router/go_router.dart';

class SpeakerDetailScreen extends StatelessWidget {
  final Speaker speaker;

  const SpeakerDetailScreen({super.key, required this.speaker});

  @override
  Widget build(BuildContext context) {
    final sessions = ConferenceData.sessionsForSpeaker(speaker.id);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (speaker.imageUrl.isNotEmpty)
                    ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0.55,
                        0,
                      ]),
                      child: Image.network(
                        speaker.imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, _, _) => Container(color: AppColors.secondary),
                      ),
                    )
                  else
                    Container(color: AppColors.secondary),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (speaker.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final tag in speaker.tags.take(2))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag.toUpperCase(),
                              style: AppTheme.heading(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryForeground,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(speaker.name, style: AppTheme.heading(fontSize: 24, height: 1.2, letterSpacing: -0.4)),
                  const SizedBox(height: 8),
                  Text(
                    speaker.roleLine.toUpperCase(),
                    style: AppTheme.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (speaker.twitterUrl != null)
                        _SocialButton(
                          icon: SvgPicture.asset(
                            'assets/icons/twitter.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(AppColors.foreground, BlendMode.srcIn),
                          ),
                          label: 'X',
                          url: speaker.twitterUrl!,
                        ),
                      if (speaker.linkedinUrl != null)
                        _SocialButton(
                          icon: SvgPicture.asset(
                            'assets/icons/linkedin.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(AppColors.foreground, BlendMode.srcIn),
                          ),
                          label: 'LinkedIn',
                          url: speaker.linkedinUrl!,
                        ),
                      if (speaker.websiteUrl != null)
                        _SocialButton(
                          icon: Icon(Icons.link_sharp, size: 16, color: AppColors.foreground),
                          label: 'Web',
                          url: speaker.websiteUrl!,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABOUT',
                    style: AppTheme.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mutedForeground,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    speaker.bio,
                    style: AppTheme.body(fontSize: 14, height: 1.6, color: AppColors.foreground.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SESSIONS',
                    style: AppTheme.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mutedForeground,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(0),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => SessionCard(
                      session: sessions[index],
                      speaker: speaker,
                      onTap: () {
                        context.push(
                          '/sessions/${sessions[index].id}',
                          extra: SessionDetailArgs(
                            session: sessions[index],
                            speakers: sessions[index].speakerIds.map(ConferenceData.speakerById).toList(),
                          ),
                        );
                      },
                    ),
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemCount: sessions.length,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label, required this.url});

  final Widget icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open $url')));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: AppTheme.heading(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
