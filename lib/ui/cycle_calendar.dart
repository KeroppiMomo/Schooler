import 'package:flutter/material.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/res/resources.dart';
import 'package:table_calendar/table_calendar.dart';

CalendarEditorResources _R = R.calendarEditor;

class CycleCalendar extends StatefulWidget {
  final CalendarController calendarController;
  final CycleConfig cycleConfig;
  final Map<DateTime, CalendarDayInfo> calendarInfo;
  final void Function(DateTime) onSelected;

  CycleCalendar({
    Key key,
    @required this.calendarController,
    @required this.cycleConfig,
    @required this.calendarInfo,
    this.onSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CycleCalendarState();
}

@visibleForTesting
class CycleCalendarState extends State<CycleCalendar> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      initialSelectedDay: widget.calendarController.focusedDay,
      initialCalendarFormat: CalendarFormat.month,
      availableCalendarFormats: {
        // There is a bug in the package
        CalendarFormat.month: 'Week',
        CalendarFormat.twoWeeks: 'Month',
        CalendarFormat.week: '2 Weeks',
      },
      calendarController: widget.calendarController,
      builders: CalendarBuilders(
        dayBuilder: (BuildContext context, DateTime dateTime, List events) =>
            dayBuilder(context, dateTime, false),
        outsideDayBuilder:
            (BuildContext context, DateTime dateTime, List events) =>
                dayBuilder(context, dateTime, true),
        outsideWeekendDayBuilder:
            (BuildContext context, DateTime dateTime, List events) =>
                dayBuilder(context, dateTime, true),
      ),
      onDaySelected: (dateTime, events) {
        widget.onSelected?.call(dateTime);
      },
    );
  }

  Widget dayBuilder(
      BuildContext context, DateTime dateTime, bool isOutsideMonth) {
    /// Change the `textStyle` color to gray if the current `dateTime` `isOutsideMonth` or not between startSchoolYear and endSchoolYear.
    /// Used for the `textStyle` of the day `Text` (the largest text for displaying the day of the month).
    TextStyle changeColorIfOutside(TextStyle textStyle) {
      return isOutsideMonth ||
              dateTime.isBefore(widget.cycleConfig.startSchoolYear) ||
              dateTime.isAfter(widget.cycleConfig.endSchoolYear
                  .add(Duration(days: 1))) // No idea why need to add 1 day
          ? textStyle.copyWith(color: _R.outsideMonthColor)
          : textStyle;
    }

    final calendarInfo =
        widget.calendarInfo[removeTimeFrom(dateTime)] ?? CalendarDayInfo();
    final contentWidget = () {
      if (calendarInfo.holidays != null) {
        if ((calendarInfo.holidays ?? '') != '') {
          return Column(
            children: <Widget>[
              Spacer(),
              Text(
                dateTime.day.toString(),
                style: _R.getCalendarDayTextTheme(context).copyWith(
                      color: _R.calendarHolidayColor,
                      decoration: calendarInfo.occasions == null
                          ? null
                          : TextDecoration.underline,
                    ),
              ),
              Text(
                calendarInfo.holidays,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: _R
                    .getCalendarDayInfoTextTheme(context)
                    .copyWith(color: _R.calendarHolidayColor),
              ),
              Spacer(),
            ],
          );
        } else {
          return Column(
            children: <Widget>[
              Spacer(),
              Text(
                dateTime.day.toString(),
                style: _R.getCalendarDayTextTheme(context).copyWith(
                      color: _R.calendarHolidayColor,
                      decoration: calendarInfo.occasions == null
                          ? null
                          : TextDecoration.underline,
                    ),
              ),
              Text(
                (calendarInfo.occasions ?? '').toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: changeColorIfOutside(
                    _R.getCalendarDayInfoTextTheme(context)),
              ),
              Spacer(),
            ],
          );
        }
      } else if (calendarInfo.occasions != null) {
        return Column(
          children: <Widget>[
            Spacer(),
            Text(
              dateTime.day.toString(),
              style: changeColorIfOutside(_R.getCalendarDayTextTheme(context))
                  .copyWith(decoration: TextDecoration.underline),
            ),
            Text(
              (calendarInfo.occasions ?? '').toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style:
                  changeColorIfOutside(_R.getCalendarDayInfoTextTheme(context)),
            ),
            Spacer(),
          ],
        );
      } else {
        return Column(
          children: <Widget>[
            Spacer(),
            Text(
              dateTime.day.toString(),
              style: changeColorIfOutside(Theme.of(context).textTheme.body1),
            ),
            Text(
              (calendarInfo.cycleDay == '1' ? '[${calendarInfo.cycle}] ' : '') +
                  (calendarInfo.cycleDay ?? '').toString(),
              textAlign: TextAlign.center,
              style:
                  changeColorIfOutside(_R.getCalendarDayInfoTextTheme(context)),
            ),
            Spacer(),
          ],
        );
      }
    }();

    if (calendarInfo.isStartSchoolYear || calendarInfo.isEndSchoolYear) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: calendarInfo.isStartSchoolYear
                  ? _R.calendarStartColor
                  : _R.calendarEndColor,
              shape: BoxShape.circle,
            ),
          ),
          contentWidget,
        ],
      );
    } else {
      return contentWidget;
    }
  }
}
