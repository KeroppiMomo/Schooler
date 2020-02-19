import 'package:flutter/material.dart';
import 'package:schooler/ui/calendar_type_screen.dart';
import 'package:schooler/ui/setup_welcome_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schooler',
      home: SetupWelcomeScreen(),
    );
  }
}
