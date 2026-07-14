import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/colors.dart';
import 'package:fluttercon2026/_utils/theme.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  static const route = '/main';

  final bool showTabBar;
  final StatefulNavigationShell child;

  const MainScreen({super.key, required this.child, this.showTabBar = false});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        bottomNavigationBar: widget.showTabBar
            ? Container(
                color: AppColors.background,
                padding: const EdgeInsets.only(top: 8),
                child: TabBar(
                  controller: tabController,
                  labelPadding: EdgeInsets.zero,
                  enableFeedback: false,
                  automaticIndicatorColorAdjustment: false,
                  indicator: null,
                  dividerColor: Colors.transparent,
                  indicatorColor: null,
                  tabs: [
                    _TabItem(
                      label: 'Sessions',
                      selected: tabController.index == 0,
                      icon: tabController.index == 0 ? Icons.calendar_today : Icons.calendar_today_outlined,
                    ),
                    _TabItem(
                      label: 'Schedule',
                      selected: tabController.index == 1,
                      icon: tabController.index == 1 ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    _TabItem(
                      label: 'Speakers',
                      selected: tabController.index == 2,
                      icon: tabController.index == 2 ? Icons.people : Icons.people_outline,
                    ),
                  ],
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        context.go('/sessions');
                        break;
                      case 1:
                        context.go('/schedule');
                        break;
                      case 2:
                        context.go('/speakers');
                        break;

                      default:
                        break;
                    }
                  },
                ),
              )
            : null,
        body: widget.child,
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.label, required this.selected, required this.icon});

  final String label;
  final bool selected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.mutedForeground;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppTheme.heading(fontSize: 9, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
