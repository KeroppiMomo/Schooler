import 'dart:io';
import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:schooler/ui/app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Settings.loadSettings();
  } catch (e) {
    print('Settings loading error:');
    print(e);
  }

  initializeLocalNotifications();

  Workmanager.initialize(
    reminderBackgroundCallback,
  );
  if (Platform.isAndroid) {
    Workmanager.registerPeriodicTask(
      '3',
      'reminderBackground',
      frequency: Duration(hours: 6),
    );
  }

  await TimeReminderCenter().registerAll(editOldDates: true);
  await Settings().saveSettings();

  // getApplicationDocumentsDirectory().then((dir) => print(dir.path));
  runApp(App());
}
