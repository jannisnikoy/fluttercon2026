import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/data/conference_data.dart';
import 'package:fluttercon2026/_utils/data/schedule_controller.dart';
import 'package:fluttercon2026/_utils/data/schedule_store.dart';
import 'package:fluttercon2026/_utils/theme.dart';
import 'package:fluttercon2026/_utils/route_generator.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConferenceData.load();
  final scheduleStore = await ScheduleStore.open();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ScheduleController(scheduleStore),
      child: MaterialApp.router(
        theme: AppTheme.dark,
        routerConfig: RouteGenerator.router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
