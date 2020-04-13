import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/main_tabs/wwidgets/reminders_wwidget.dart';
import 'package:schooler/ui/main_tabs/wwidgets/timetable_wwidget.dart';
import 'package:schooler/ui/main_tabs/wwidgets/assignments_wwidget.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:intl/intl.dart';

final TodayTabResources _R = R.todayTab;

class TodayTab extends StatefulWidget {
  @override
  TodayTabState createState() => TodayTabState();
}

class TodayTabState extends State<TodayTab> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // final now = DateTime(2020, 1, 6, 11, 30);

    final dayInfo = () {
      if (Settings().calendarType == CalendarType.week) {
        return Settings().weekConfig.getCalendar();
      } else if (Settings().calendarType == CalendarType.cycle) {
        return Settings().cycleConfig.getCalendar();
      } else {
        assert(false, 'Unexpected CalendarType value');
        return null;
      }
    }()[removeTimeFrom(now)];

    final dayDescription = () {
      if (dayInfo == null)
        return '';
      else {
        final dayDescriptionComponents = <String>[];
        if (Settings().calendarType == CalendarType.week) {
          dayDescriptionComponents.add(DateFormat('EEEE').format(now));
        } else if (Settings().calendarType == CalendarType.cycle) {
          if (dayInfo.cycleDay != null && dayInfo.cycle != null) {
            dayDescriptionComponents
                .add(_R.getDescriptionComponentCycleDay(dayInfo.cycleDay));
            dayDescriptionComponents
                .add(_R.getDescriptionComponentCycle(dayInfo.cycle.toString()));
          }
        } else {
          assert(false, 'Unexpected CalendarType value');
        }
        if (dayInfo.holidays != null) {
          if (dayInfo.holidays == '') {
            dayDescriptionComponents.add(_R.descriptionWeekendText);
          } else {
            dayDescriptionComponents.add(dayInfo.holidays);
          }
        }
        if (dayInfo.occasions != null && dayInfo.occasions != '') {
          dayDescriptionComponents.add(dayInfo.occasions);
        }
        return dayDescriptionComponents.join(', ');
      }
    }();

    return Scaffold(
      appBar: AppBar(
        title: Text(_R.appBarTitle),
      ),
      body: ListView(
        padding: _R.listViewPadding,
        children: [
          Text(
            _R.dateFormat.format(now),
            textAlign: TextAlign.right,
            style: _R.getDateTextStyle(context),
          ),
          Text(
            dayDescription,
            textAlign: TextAlign.right,
            style: _R.getDayDescriptionTextStyle(context),
          ),
          SizedBox(height: _R.dayWWidgetsSpacing),
          TimetableWWidget(now: now, dayInfo: dayInfo),
          AssignmentsWWidget(now: now),
          RemindersWWidget(),
        ],
      ),
    );
  }
}
