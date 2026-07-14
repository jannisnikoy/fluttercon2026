import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttercon2026/_utils/colors.dart';
import 'package:fluttercon2026/_utils/data/conference_data.dart';
import 'package:fluttercon2026/_utils/data/schedule_controller.dart';
import 'package:fluttercon2026/_utils/data/models.dart';
import 'package:fluttercon2026/_utils/theme.dart';
import 'package:fluttercon2026/_utils/widgets/avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionDetailArgs {
  final Session session;
  final List<Speaker> speakers;

  const SessionDetailArgs({required this.session, required this.speakers});
}

class SessionDetailScreen extends StatelessWidget {
  final SessionDetailArgs args;

  const SessionDetailScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final related = args.session.relatedSessionIds.map(ConferenceData.sessionById).toList();
    final schedule = context.watch<ScheduleController>();
    final bookmarked = schedule.isBookmarked(args.session.id);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              schedule.toggleBookmark(args.session.id);
            },
            icon: Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: bookmarked ? AppColors.primary : AppColors.foreground,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              if (args.session.track != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(args.session.accentColor),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    displayTrackLabel(args.session.track!).toUpperCase(),
                    style: AppTheme.heading(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryForeground,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

              Text(args.session.title, style: AppTheme.heading(fontSize: 24, height: 1.2, letterSpacing: -0.4)),
              const SizedBox(height: 48),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.8,
                children: [
                  _MetaItem(
                    icon: Icons.calendar_today,
                    accentColor: Color(args.session.accentColor),
                    label: 'Date',
                    value: formatDayLong(args.session.day),
                  ),
                  _MetaItem(
                    icon: Icons.access_time,
                    accentColor: Color(args.session.accentColor),
                    label: 'Time',
                    value: formatTimeRange(args.session.start, args.session.end),
                  ),
                  _MetaItem(
                    icon: Icons.location_on_outlined,
                    accentColor: Color(args.session.accentColor),
                    label: 'Location',
                    value: args.session.room,
                  ),
                  _MetaItem(
                    icon: Icons.groups,
                    accentColor: Color(args.session.accentColor),
                    label: 'Track',
                    value: args.session.track != null
                        ? displayTrackLabel(args.session.track!)
                        : (args.session.typeLabel ?? 'General'),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              Text(
                'ABOUT THIS SESSION',
                style: AppTheme.heading(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedForeground,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              for (final para in args.session.description.split('\n\n')) ...[
                Text(
                  para,
                  style: AppTheme.body(fontSize: 14, height: 1.6, color: AppColors.foreground.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 12),
              ],

              if (args.speakers.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        args.speakers.length == 1 ? 'ABOUT THE SPEAKER' : 'ABOUT THE SPEAKERS',
                        style: AppTheme.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mutedForeground,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      for (final speaker in args.speakers) ...[
                        GestureDetector(
                          onTap: () {
                            context.push('/speakers/${speaker.id}', extra: speaker);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: GrayscaleAvatar(url: speaker.imageUrl, size: 60),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(speaker.name, style: AppTheme.heading(fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(
                                      speaker.roleLine.toUpperCase(),
                                      style: AppTheme.heading(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (speaker.twitterUrl != null)
                                          _SocialIcon(
                                            icon: SvgPicture.asset(
                                              'assets/icons/twitter.svg',
                                              width: 22,
                                              height: 22,
                                              colorFilter: const ColorFilter.mode(
                                                AppColors.mutedForeground,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            url: speaker.twitterUrl!,
                                          ),
                                        if (speaker.linkedinUrl != null)
                                          _SocialIcon(
                                            icon: SvgPicture.asset(
                                              'assets/icons/linkedin.svg',
                                              width: 22,
                                              height: 22,
                                              colorFilter: const ColorFilter.mode(
                                                AppColors.mutedForeground,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            url: speaker.linkedinUrl!,
                                          ),
                                        if (speaker.websiteUrl != null)
                                          _SocialIcon(
                                            icon: Icon(Icons.link_sharp, size: 22, color: AppColors.mutedForeground),
                                            url: speaker.websiteUrl!,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (speaker.bio.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            speaker.bio,
                            style: AppTheme.body(
                              fontSize: 12,
                              height: 1.5,
                              color: AppColors.mutedForeground,
                            ).copyWith(fontStyle: FontStyle.italic),
                            maxLines: args.speakers.length > 1 ? 4 : null,
                            overflow: args.speakers.length > 1 ? TextOverflow.ellipsis : TextOverflow.visible,
                          ),
                        ],
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            context.push('/speakers/${speaker.id}', extra: speaker);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'VIEW FULL SPEAKER PROFILE',
                              textAlign: TextAlign.center,
                              style: AppTheme.heading(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                        ),
                        if (speaker != args.speakers.last)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Divider(color: AppColors.border, height: 1),
                          ),
                      ],
                    ],
                  ),
                ),

              // Related sessions
              if (related.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RELATED SESSIONS',
                        style: AppTheme.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mutedForeground,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      for (final relatedSession in related) ...[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => SessionDetailScreen(
                                  args: SessionDetailArgs(
                                    session: relatedSession,
                                    speakers: relatedSession.speakerIds
                                        .map((e) => ConferenceData.speakerById(e))
                                        .toList(),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(relatedSession.accentColor),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${relatedSession.track != null ? displayTrackLabel(relatedSession.track!) : (relatedSession.typeLabel ?? '')} • ${formatDayLong(relatedSession.day).split(',').first} ${formatTime(relatedSession.start)}'
                                            .toUpperCase(),
                                        style: AppTheme.heading(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(relatedSession.accentColor),
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        relatedSession.title,
                                        style: AppTheme.body(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, size: 16, color: AppColors.mutedForeground),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  String formatAmPm(DateTime dt) => DateFormat('a').format(dt).toUpperCase();

  String formatTimeRange(DateTime start, DateTime end) {
    final startStr = DateFormat('HH:mm a').format(start);
    final endStr = DateFormat('HH:mm a').format(end);
    return '$startStr - $endStr';
  }

  String formatDayLong(DateTime day) => DateFormat('EEE, MMM d').format(day);

  String formatDaySection(DateTime day) => DateFormat('EEEE, MMM d').format(day);
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.accentColor, required this.label, required this.value});

  final IconData icon;
  final Color accentColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTheme.heading(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedForeground,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                value,
                style: AppTheme.body(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.url});

  final Widget icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        },
        child: icon,
      ),
    );
  }
}
