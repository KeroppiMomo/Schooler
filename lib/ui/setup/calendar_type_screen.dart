import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/setup/cycles_editor_screen.dart';
import 'package:schooler/ui/setup/weeks_editor_screen.dart';

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
    final onPop = () {
      Settings().calendarType = null;
      Settings().saveSettings();
    };

    void push(Widget screen) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }

    if (selectedType == CalendarType.week) {
      push(WeeksEditorScreen(onPop: onPop));
    } else if (selectedType == CalendarType.cycle) {
      push(CyclesEditorScreen(onPop: onPop));
    } else {
      assert(false, 'Unexpected CalendarType value');
    }
  }
}
