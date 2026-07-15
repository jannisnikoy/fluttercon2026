import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/colors.dart';
import 'package:fluttercon2026/_utils/data/conference_data.dart';
import 'package:fluttercon2026/_utils/data/models.dart';
import 'package:fluttercon2026/_utils/theme.dart';
import 'package:fluttercon2026/_utils/widgets/day_selector.dart';
import 'package:fluttercon2026/_utils/widgets/session_card.dart';
import 'package:fluttercon2026/_utils/widgets/track_chip.dart';
import 'package:fluttercon2026/screens/session_detail_screen.dart';
import 'package:go_router/go_router.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreen();
}

class _SessionsScreen extends State<SessionsScreen> {
  late DateTime _selectedDay;

  String _query = '';
  String _trackFilter = 'All Tracks';
  final _searchController = TextEditingController();

  final _controlsKey = GlobalKey();
  double _controlsHeight = 170;

  @override
  void initState() {
    super.initState();
    _selectedDay = ConferenceData.days.first.date;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Session> get _filtered {
    var list = ConferenceData.sessionsForDay(_selectedDay);
    if (_trackFilter != 'All Tracks') {
      list = list.where((s) => ConferenceData.matchesTrackFilter(s, _trackFilter)).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((s) {
        if (s.title.toLowerCase().contains(q)) return true;
        for (final id in s.speakerIds) {
          if (ConferenceData.speakerById(id).name.toLowerCase().contains(q)) {
            return true;
          }
        }
        return false;
      }).toList();
    }
    return list;
  }

  void _measureControls() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final height = _controlsKey.currentContext?.size?.height;
      if (height != null && (height - _controlsHeight).abs() > 0.5) {
        setState(() => _controlsHeight = height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _measureControls();
    final sessions = _filtered;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTitle()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ControlsHeaderDelegate(height: _controlsHeight, child: _buildControls()),
            ),
            if (sessions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      'No sessions match your filters.',
                      style: AppTheme.body(color: AppColors.mutedForeground),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                sliver: SliverList.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final speakers = session.speakerIds.map((e) => ConferenceData.speakerById(e)).toList();

                    return session.isBreak
                        ? BreakCard(session: session)
                        : SessionCard(
                            session: session,
                            speaker: speakers.first,
                            onTap: () {
                              context.push(
                                '/sessions/${session.id}',
                                extra: SessionDetailArgs(session: session, speakers: speakers),
                              );
                            },
                          );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text('FlutterCon USA 2026', style: AppTheme.heading(fontSize: 20, letterSpacing: -0.3)),
          Text(
            'Orlando, FL',
            style: AppTheme.heading(fontSize: 10, color: AppColors.mutedForeground, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      key: _controlsKey,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {
                  _query = query;
                });
              },
              style: AppTheme.body(fontSize: 14),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search for sessions',
                hintStyle: AppTheme.body(fontSize: 14, color: AppColors.mutedForeground),
                filled: true,
                fillColor: AppColors.input,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.mutedForeground),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final track in ConferenceData.trackFilters) ...[
                  TrackChip(
                    label: track,
                    selected: _trackFilter == track,
                    onTap: () {
                      setState(() => _trackFilter = track);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          DaySelector(selected: _selectedDay, onChanged: (d) => setState(() => _selectedDay = d)),
        ],
      ),
    );
  }
}

class _ControlsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ControlsHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
      child: OverflowBox(alignment: Alignment.topCenter, minHeight: 0, maxHeight: double.infinity, child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _ControlsHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
