import 'package:flutter/material.dart';
import 'package:schooler/ui/cycles_editor.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello',
      home: CyclesEditorScreen(),
    );
  }
}