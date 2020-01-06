import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Settings.loadSettings();
  } catch (e) {}
  runApp(App());
}
