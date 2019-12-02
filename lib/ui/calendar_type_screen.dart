import 'package:flutter/material.dart';
import 'package:schooler/ui/cycles_editor.dart';

class CalendarTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              child: Text('By Weeks'),
              onPressed: () {},
            ),
            RaisedButton(
              child: Text('By Cycles'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CyclesEditorScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
