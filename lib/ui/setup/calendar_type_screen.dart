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
                padding: _R.padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      _R.headerText,
                      style: _R.getHeaderStyle(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: _R.headerChoicesSpacing),
                    _buildChoice(
                      title: _R.weekTitle,
                      description: _R.weekDescription,
                      image: _R.weekImage,
                      onTap: () => _typeButtonPressed(context,
                          selectedType: CalendarType.week),
                    ),
                    SizedBox(height: _R.weekCycleSpacing),
                    _buildChoice(
                      title: _R.cycleTitle,
                      description: _R.cycleDescription,
                      image: _R.cycleImage,
                      onTap: () => _typeButtonPressed(context,
                          selectedType: CalendarType.cycle),
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
        elevation: _R.cardElevation,
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(height: _R.cardImageSpacing),
              Image(
                image: image,
                height: _R.cardImageHeight,
              ),
              SizedBox(height: _R.cardImageTitleSpacing),
              Text(
                title,
                style: _R.getTitleStyle(context),
              ),
              SizedBox(height: _R.cardTitleDescriptionSpacing),
              Text(
                description,
                style: _R.getDescriptionStyle(context),
              ),
              SizedBox(height: _R.cardDescriptionSpacing),
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
