import 'package:flutter/material.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/setup/timetable_editor.dart';
import 'package:schooler/ui/setup/subject_editor_screen.dart';

TimetableEditorScreenResources _R = R.timetableEditorScreen;

class TimetableEditorScreen extends StatefulWidget {
  final void Function() onPop;
  final void Function() onDone;
  final bool isSetup;

  TimetableEditorScreen({this.onPop, this.onDone, this.isSetup = true});

  @override
  State createState() => TimetableEditorScreenState();
}

@visibleForTesting
class TimetableEditorScreenState extends State<TimetableEditorScreen> {
  TextEditingController _addTimetableNameController;

  @override
  void initState() {
    super.initState();

    if (widget.isSetup) {
      if (Settings().timetable != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _donePressed();
        });
      }
    }

    if (Settings().timetable == null) {
      if (Settings().calendarType == CalendarType.cycle) {
        Settings().timetable =
            Timetable.defaultFromCycleConfig(Settings().cycleConfig);
      } else if (Settings().calendarType == CalendarType.week) {
        Settings().timetable =
            Timetable.defaultFromWeekConfig(Settings().weekConfig);
      } else {
        assert(false, 'Unexpected CalendarType value');
      }
    }
    Settings().saveSettings();

    _addTimetableNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final dismiss = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_R.popConfirmTitle),
            content: Text(_R.popConfirmMessage),
            actions: <Widget>[
              FlatButton(
                child: Text(_R.popConfirmCancelText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text(_R.popConfirmDiscardText),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
        if (!(dismiss ?? false)) return false;
        widget.onPop?.call();
        return true;
      },
      child: DefaultTabController(
        length: Settings().timetable.noOfDays + 1, // +1 is the "add" tab
        child: Scaffold(
          appBar: AppBar(
            leading: widget.isSetup
                ? BackButton(
                    onPressed: () => Navigator.maybePop(context),
                  )
                : IconButton(
                    icon: Icon(_R.dismissIcon),
                    onPressed: () => Navigator.maybePop(context),
                  ),
            title: Text(_R.appBarTitle),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                ...Settings().timetable.days.map((TimetableDay day) {
                  String name = '';
                  if (day is TimetableWeekDay) {
                    name = _R.weekDayTabName(day.dayOfWeek);
                  } else if (day is TimetableCycleDay) {
                    name = _R.cycleDayTabName(day.dayOfCycle);
                  } else if (day is TimetableOccasionDay) {
                    name = day.occasionName;
                  } else {
                    assert(false, 'Unexpected Timetableday subtype');
                  }

                  return Tab(text: name);
                }),
                Tab(icon: Icon(_R.addTabIcon)),
              ],
            ),
          ),
          body: Builder(
            builder: (context) => SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: TabBarView(
                      children: [
                        ...Settings()
                            .timetable
                            .timetable
                            .keys
                            .map(_buildTimetable),
                        _buildAddDay(context),
                      ],
                    ),
                  ),
                  Divider(),
                  FlatButton(
                    child: Text(_R.doneButtonText),
                    onPressed: _donePressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimetable(TimetableDay day) {
    return TimetableEditor(
      sessions: Settings().timetable.sessionsOfDay(day),
      onDelete: (int i) {
        Settings().timetable.sessionsOfDay(day).removeAt(i);
        Settings().saveSettings();
      },
      onAdd: () {
        final sessions = Settings().timetable.sessionsOfDay(day);
        final newSession = () {
          if (sessions.length == 0) {
            return TimetableSession(
                startTime: _R.sessionDefaultStartTime,
                endTime:
                    _R.sessionDefaultStartTime.add(_R.sessionDefaultDuration),
                name: '');
          } else {
            final lastSession = sessions.last;
            return TimetableSession(
              startTime: lastSession.endTime,
              endTime: lastSession.endTime
                  .add(lastSession.endTime.difference(lastSession.startTime)),
              name: '',
            );
          }
        }();
        Settings().timetable.sessionsOfDay(day).add(newSession);
        Settings().saveSettings();
      },
      onStartTimeChange: (int i, DateTime newTime) {
        Settings().timetable.sessionsOfDay(day)[i].startTime = newTime;
        Settings().saveSettings();
      },
      onEndTimeChange: (int i, DateTime newTime) {
        Settings().timetable.sessionsOfDay(day)[i].endTime = newTime;
        Settings().saveSettings();
      },
      onNameChange: (int i, String newName) {
        Settings().timetable.sessionsOfDay(day)[i].name = newName;
        Settings().saveSettings();
      },
      onCopyTimeSlots: (TimetableDay copyDay) {
        List<TimetableSession> copySessions =
            Settings().timetable.sessionsOfDay(copyDay);
        for (final copySession in copySessions) {
          Settings().timetable.sessionsOfDay(day).add(
                TimetableSession(
                  startTime: copySession.startTime,
                  endTime: copySession.endTime,
                  name: '',
                ),
              );
        }
        Settings().saveSettings();
      },
      onRemoveDay:
          day is TimetableOccasionDay ? () => _removeTimetableDay(day) : null,
    );
  }

  Widget _buildAddDay(BuildContext context) {
    Widget buildButtonsCard(String title, List<String> names) {
      return Card(
        child: Padding(
          padding: _R.addTabButtonsCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: _R.getAddTabButtonsCardTitleStyle(context),
              ),
              Divider(),
              ...names
                  .map((name) => FlatButton.icon(
                        icon: Icon(_R.addTabButtonsIcon),
                        label: Text(name),
                        onPressed: () => _addTimetableDay(context, name),
                      ))
                  .toList(),
            ],
          ),
        ),
      );
    }

    final dynamic calendar = () {
      if (Settings().calendarType == CalendarType.week)
        return Settings().weekConfig;
      else if (Settings().calendarType == CalendarType.cycle)
        return Settings().cycleConfig;
      else {
        assert(false, 'Unexpected CalendarType value');
        return null;
      }
    }();

    var existingTimetableNames = List<String>();
    for (final day in Settings().timetable.days) {
      if (day is TimetableOccasionDay) {
        existingTimetableNames.add(day.occasionName);
      }
    }

    final availableHolidayNames =
        Set<String>.from(calendar.holidays.map((event) => event.name));
    availableHolidayNames.removeAll(existingTimetableNames);

    final availableOccasionNames =
        Set<String>.from(calendar.occasions.map((event) => event.name));
    availableOccasionNames.removeAll(existingTimetableNames);

    final contentWidgets = <Widget>[];
    if (availableOccasionNames.length == 0 &&
        availableHolidayNames.length == 0) {
      contentWidgets.add(Text(
        _R.addTabNoEventMessage,
        textAlign: TextAlign.center,
        style: _R.getAddTabNoEventTextStyle(context),
      ));
      contentWidgets.add(SizedBox(height: _R.addTabWidgetSpacing));
    } else {
      if (availableOccasionNames.length != 0) {
        contentWidgets.add(buildButtonsCard(
            _R.addTabOccasionButtonsTitle, availableOccasionNames.toList()));
        contentWidgets.add(SizedBox(height: _R.addTabWidgetSpacing));
      }
      if (availableHolidayNames.length != 0) {
        contentWidgets.add(buildButtonsCard(
            _R.addTabHolidaysButtonsTitle, availableHolidayNames.toList()));
        contentWidgets.add(SizedBox(height: _R.addTabWidgetSpacing));
      }
    }

    return ListView(
      padding: EdgeInsets.all(_R.addTabWidgetSpacing),
      children: <Widget>[
        Text(
          _R.addTabButtonsText,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: _R.addTabWidgetSpacing),
        ...contentWidgets,
        Text(
          _R.addTabInputNameText,
          textAlign: TextAlign.center,
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addTimetableNameController,
                decoration: InputDecoration(
                    labelText: _R.addTabInputNameTextFieldLabel),
                onSubmitted: (text) => _addTimetableDay(context, text),
              ),
            ),
            IconButton(
              icon: Icon(_R.addTabInputNameButtonIcon),
              onPressed: () =>
                  _addTimetableDay(context, _addTimetableNameController.text),
            ),
          ],
        ),
      ],
    );
  }

  void _addTimetableDay(BuildContext context, String name) {
    name = name.trim();
    if (name == '') return;
    if (Settings()
        .timetable
        .timetable
        .containsKey(TimetableOccasionDay(name))) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(_R.getAddTabInputNameExistMessage(name)),
      ));
      return;
    }
    _addTimetableNameController.clear();
    setState(() {
      Settings().timetable.timetable[TimetableOccasionDay(name)] = [];
    });
  }

  void _removeTimetableDay(TimetableDay day) {
    setState(() {
      Settings().timetable.timetable.remove(day);
      Settings().saveSettings();
    });
  }

  void _donePressed() {
    if (widget.isSetup) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SubjectEditorScreen(
          onPop: () {
            Settings().subjects = null;
            Settings().saveSettings();
          },
        ),
      ));
    } else {
      widget.onDone?.call();
      Navigator.of(context).pop();
    }
  }
}
