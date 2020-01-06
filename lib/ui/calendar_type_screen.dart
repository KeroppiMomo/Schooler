import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/cycles_editor_screen.dart';

final CalendarTypeScreenResources _R = R.calendarType;

class CalendarTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Settings().calendarType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _typeButtonPressed(context, selectedType: Settings().calendarType);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_R.appBarTitle),
      ),
      body: Padding(
        padding: _R.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: CalendarType.values
              .map((type) => RaisedButton(
                    child: Text(_R.buttonTextForTypes[type]),
                    onPressed: () =>
                        _typeButtonPressed(context, selectedType: type),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _typeButtonPressed(BuildContext context,
      {@required CalendarType selectedType}) {
    Settings().calendarType = selectedType;
    Settings().saveSettings();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CyclesEditorScreen(onPop: () {
              Settings().calendarType = null;
              Settings().saveSettings();
            })));
  }
}
