import 'package:flutter/material.dart';
import 'package:schooler/ui/setup/setup_welcome_screen.dart';
import 'package:schooler/ui/main_screen.dart';
import 'package:schooler/lib/settings.dart';

class App extends StatelessWidget {
  /// If true, navigation is forced to run through the setup.
  /// Note that setting this value to true doesn't change the value to `Settings().isSetupCompleted`.
  final bool forceSetup;
  App({Key key, this.forceSetup = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schooler',
      home: (Settings().isSetupCompleted && !forceSetup)
          ? MainScreen()
          : SetupWelcomeScreen(),
    );
  }
}
