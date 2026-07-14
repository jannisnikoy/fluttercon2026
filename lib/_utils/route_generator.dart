import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/data/models.dart';
import 'package:fluttercon2026/screens/loading_screen.dart';
import 'package:fluttercon2026/screens/schedule_screen.dart';
import 'package:fluttercon2026/screens/session_detail_screen.dart';
import 'package:fluttercon2026/screens/sessions_screen.dart';
import 'package:fluttercon2026/screens/main_screen.dart';
import 'package:fluttercon2026/screens/speaker_detail_screen.dart';
import 'package:fluttercon2026/screens/speakers_screen.dart';
import 'package:go_router/go_router.dart';

class RouteGenerator {
  static final GlobalKey<NavigatorState> parentNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> agendaTabNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> scheduleTabNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> speakersTabNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
    initialLocation: '/',
    navigatorKey: parentNavigatorKey,
    routes: [
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          StatefulShellRoute.indexedStack(
            branches: [
              StatefulShellBranch(
                navigatorKey: agendaTabNavigatorKey,
                routes: [
                  GoRoute(
                    path: '/sessions',
                    pageBuilder: (context, GoRouterState state) {
                      return MaterialPage(key: state.pageKey, child: const SessionsScreen());
                    },
                    routes: [
                      GoRoute(
                        path: ':id',
                        pageBuilder: (context, GoRouterState state) {
                          return MaterialPage(
                            key: state.pageKey,
                            child: SessionDetailScreen(args: state.extra as SessionDetailArgs),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: scheduleTabNavigatorKey,
                routes: [
                  GoRoute(
                    path: '/schedule',
                    pageBuilder: (context, GoRouterState state) {
                      return MaterialPage(key: state.pageKey, child: ScheduleScreen());
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: speakersTabNavigatorKey,
                routes: [
                  GoRoute(
                    path: '/speakers',
                    pageBuilder: (context, GoRouterState state) {
                      return MaterialPage(key: state.pageKey, child: SpeakersScreen());
                    },
                    routes: [
                      GoRoute(
                        path: ':id',
                        pageBuilder: (context, GoRouterState state) {
                          return MaterialPage(
                            key: state.pageKey,
                            child: SpeakerDetailScreen(speaker: state.extra as Speaker),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
            pageBuilder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
              final showTabBar =
                  state.fullPath == '/sessions' ||
                  state.fullPath == '/schedule' ||
                  state.fullPath == '/speakers' ||
                  state.fullPath == '/settings';

              return CustomTransitionPage<void>(
                key: state.pageKey,
                transitionDuration: const Duration(milliseconds: 350),
                transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
                child: MainScreen(showTabBar: showTabBar, child: navigationShell),
              );
            },
          ),
          GoRoute(path: '/', builder: (context, state) => const LoadingScreen()),
        ],
      ),
    ],
  );
}
