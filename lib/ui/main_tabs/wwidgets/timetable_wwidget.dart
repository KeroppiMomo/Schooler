import 'dart:math';
import 'package:flutter/material.dart';
import 'package:schooler/ui/main_tabs/wwidgets/wwidget.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:intl/intl.dart';

TimetableWWidgetResources _R = R.timetableWWidget;

class TimetableWWidget extends StatefulWidget {
  final DateTime now;
  final CalendarDayInfo dayInfo;

  TimetableWWidget({Key key, @required this.now, @required this.dayInfo})
      : assert(now != null),
        assert(dayInfo != null),
        super(key: key);

  @override
  TimetableWWidgetState createState() => TimetableWWidgetState();
}

class TimetableWWidgetState extends State<TimetableWWidget> {
  @override
  Widget build(BuildContext context) {
    final timetableDay = () {
      final existingDays = Settings().timetable.days;
      for (final holiday in widget.dayInfo.holidays?.split(', ') ?? []) {
        final day = TimetableOccasionDay(holiday);
        if (existingDays.contains(day)) return day;
      }
      for (final occasion in widget.dayInfo.holidays?.split(', ') ?? []) {
        final day = TimetableOccasionDay(occasion);
        if (existingDays.contains(day)) return day;
      }

      if (Settings().calendarType == CalendarType.week) {
        final day = TimetableWeekDay(widget.now.weekday);
        if (existingDays.contains(day)) return day;
      } else if (Settings().calendarType == CalendarType.cycle) {
        if (widget.dayInfo.cycleDay != null) {
          final day = TimetableCycleDay(int.parse(widget.dayInfo.cycleDay));
          if (existingDays.contains(day)) return day;
        }
      } else {
        assert(false, 'Unexpected CalendarType value');
      }
      return null;
    }();
    final List<TimetableSession> sessions = timetableDay == null
        ? []
        : Settings().timetable.sessionsOfDay(timetableDay);

    final shownSessions = _getShownSessions(sessions);

    final sessionWidgets = shownSessions.map(
      (session) {
        final subject = Settings().subjects.firstWhere(
              (subject) => subject.name == session.name,
              orElse: () => null,
            );
        final timestampStyle = () {
          final nowTime = DateTime(1970, 1, 1, widget.now.hour,
              widget.now.minute, widget.now.second);
          final startTime = DateTime(1970, 1, 1, session.startTime.hour,
              session.startTime.minute, session.startTime.second);
          final endTime = DateTime(1970, 1, 1, session.endTime.hour,
              session.endTime.minute, session.endTime.second);

          if (nowTime.compareTo(startTime) >= 0 &&
              nowTime.compareTo(endTime) < 0) {
            return _R.currentTimestampTextStyle(context);
          } else if (nowTime.compareTo(startTime) < 0) {
            return _R.afterTimestampTextStyle(context);
          } else {
            return _R.beforeTimestampTextStyle(context);
          }
        }();

        return TableRow(children: [
          Center(
              child: Text(_R.timestampFormat.format(session.startTime),
                  style: timestampStyle)),
          Center(child: Text(_R.sessionTimeTo)),
          Center(
              child: Text(_R.timestampFormat.format(session.endTime),
                  style: timestampStyle)),
          Container(),
          SubjectBlock(
            name: session.name,
            color: subject?.color ?? Color(0x00FFFFFF),
            // Why Color(0x00FFFFFF) instead of Colors.transparent:
            // SubjectBlock uses color to determine the color of the text.
            // Colors.transparent (0x00000000): Brightness.dark
            // Colors(0x00FFFFFF):              Brightness.light
            // So the text color is black on Color(0x00FFFFFF).
          ),
        ]);
      },
    ).toList();

    return WWidget(
      title: _R.wwidgetTitle,
      icon: _R.wwidgetIcon,
      child: Column(
        children: [
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: IntrinsicColumnWidth(),
              1: FixedColumnWidth(_R.columnTimeToWidth),
              2: IntrinsicColumnWidth(),
              3: FixedColumnWidth(_R.timestampNameSpacing),
            },
            children: sessionWidgets,
          ),
          FlatButton.icon(
            icon: Icon(_R.viewTimetableIcon),
            label: Text(timetableDay == null
                ? _R.viewNoTimetableText
                : _R.viewTimetableText(timetableDay)),
            onPressed: () {},
          ),
        ],
      ),
      onSettingsPressed: () {},
    );
  }

  List<TimetableSession> _getShownSessions(List<TimetableSession> sessions) {
    final currentSessionIndex = () {
      for (int i = 0; i < sessions.length; i++) {
        final session = sessions[i];

        final nowTime = DateTime(
            1970, 1, 1, widget.now.hour, widget.now.minute, widget.now.second);
        final startTime = DateTime(1970, 1, 1, session.startTime.hour,
            session.startTime.minute, session.startTime.second);
        final endTime = DateTime(1970, 1, 1, session.endTime.hour,
            session.endTime.minute, session.endTime.second);

        if (nowTime.compareTo(endTime) < 0) return i;
      }
      return sessions.length - 1;
    }();

    // Show maximum 4 sessions, maximum 1 session before current session.
    // This is stolen from my another project 'flows' at lib/ui/custom_widgets/flow_widget:104.
    int start, end;
    if (currentSessionIndex == 0) {
      start = 0;
      end = min(sessions.length, 4);
    } else if (sessions.length - currentSessionIndex < 3) {
      start = max(0, sessions.length - 4);
      end = sessions.length;
    } else {
      start = currentSessionIndex - 1;
      end = currentSessionIndex + 3;
    }
    return sessions.sublist(start, end);
  }
}
