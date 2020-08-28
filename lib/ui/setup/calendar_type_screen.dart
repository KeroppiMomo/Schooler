import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/setup/cycles_editor_screen.dart';
import 'package:schooler/ui/setup/weeks_editor_screen.dart';

final CalendarTypeScreenResources _R = R.calendarType;

class CalendarTypeScreen extends StatefulWidget {
  @override
  CalendarTypeScreenState createState() => CalendarTypeScreenState();
}

class CalendarTypeScreenState extends State<CalendarTypeScreen> {
  @override
  void initState() {
    super.initState();

    if (Settings().calendarType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _typeButtonPressed(context, selectedType: Settings().calendarType);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_R.appBarTitle),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Choose your calendar type.',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.0),
                    _buildChoice(
                      title: 'By Week',
                      description: 'Timetable for Monday, Tuesday, etc.',
                      image: AssetImage('lib/res/calendar_type_week_icon.png'),
                      onTap: () => _typeButtonPressed(context, selectedType: CalendarType.week),
                    ),
                    SizedBox(height: 16.0),
                    _buildChoice(
                      title: 'By Cycle',
                      description: 'Timetable for Day 1, Day 2, etc.',
                      image: AssetImage('lib/res/calendar_type_cycle_icon.png'),
                      onTap: () => _typeButtonPressed(context, selectedType: CalendarType.cycle),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoice({
    String title,
    String description,
    ImageProvider image,
    void Function() onTap,
  }) =>
      Card(
        elevation: 3.0,
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(height: 32.0),
              Image(
                image: image,
                height: 100.0,
              ),
              SizedBox(height: 32.0),
              Text(
                title,
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 8.0),
              Text(
                description,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 32.0),
            ],
          ),
          onTap: onTap,
        ),
      );

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
