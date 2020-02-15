import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/ui/app.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Settings.loadSettings();
  } catch (e) {
    print('Settings loading error:');
    print(e);
  }
  // getApplicationDocumentsDirectory().then((dir) => print(dir.path));
  runApp(App());
}
