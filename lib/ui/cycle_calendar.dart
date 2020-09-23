import 'package:flutter/material.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/res/resources.dart';
import 'package:table_calendar/table_calendar.dart';

CalendarEditorResources _R = R.calendarEditor;

class CycleCalendar extends StatefulWidget {
  final CalendarController calendarController;
  final CycleConfig cycleConfig;
  final Map<DateTime, CalendarDayInfo> calendarInfo;
  final Future<void> Function(DateTime dateTime, Offset tapPosition) onSelected;
  final Future<void> Function(DateTimeRange dateTimeRange, Offset tapPosition)
      onRangeSelected;

  CycleCalendar({
    Key key,
    @required this.calendarController,
    @required this.cycleConfig,
    @required this.calendarInfo,
    this.onSelected,
    this.onRangeSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CycleCalendarState();
}

@visibleForTesting
class CycleCalendarState extends State<CycleCalendar> {
  /// Selected dates when it is pressed or dragged.
  DateTime _selectedDateStart;
  DateTime _selectedDateEnd;

  Map<Rect, DateTime> _datePosition = {};

  DateTime _getDateTimeFromPosition(Offset position) {
    for (final entry in _datePosition.entries) {
      if (position.dx >= entry.key.left &&
          position.dx < entry.key.right &&
          position.dy >= entry.key.top &&
          position.dy < entry.key.bottom) {
        return entry.value;
      }
    }
    return null;
  }

  Rect _getPositionFromDateTime(DateTime dateTime) {
    for (final entry in _datePosition.entries) {
      if (removeTimeFrom(entry.value) == removeTimeFrom(dateTime)) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      initialSelectedDay: widget.calendarController.focusedDay,
      initialCalendarFormat: CalendarFormat.month,
      availableCalendarFormats: {
        CalendarFormat.month: '',
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
        if (calendarInfo.holidays.isNotEmpty) {
          return Ink(
            color: _R.calendarHolidayFillColor,
            child: Column(
              children: <Widget>[
                Spacer(),
                Text(
                  dateTime.day.toString(),
                  style: _R.getCalendarDayTextTheme(context).copyWith(
                        color: _R.calendarHolidayTextColor,
                        decoration: calendarInfo.occasions == null
                            ? null
                            : TextDecoration.underline,
                      ),
                ),
                Text(
                  calendarInfo.holidays.map((e) => e.name).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: _R
                      .getCalendarDayInfoTextTheme(context)
                      .copyWith(color: _R.calendarHolidayTextColor),
                ),
                Spacer(),
              ],
            ),
          );
        } else {
          return Ink(
            color: calendarInfo.occasions == null ? null : _R.calendarOccasionFillColor,
            child: Column(
              children: <Widget>[
                Spacer(),
                Text(
                  dateTime.day.toString(),
                  style: _R.getCalendarDayTextTheme(context).copyWith(
                        color: _R.calendarHolidayTextColor,
                        decoration: calendarInfo.occasions == null
                            ? null
                            : TextDecoration.underline,
                      ),
                ),
                Text(
                  calendarInfo.occasions?.map((e) => e.name)?.join(', ') ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: changeColorIfOutside(
                      _R.getCalendarDayInfoTextTheme(context)),
                ),
                Spacer(),
              ],
            ),
          );
        }
      } else if (calendarInfo.occasions != null) {
        return Ink(
          color: _R.calendarOccasionFillColor,
          child: Column(
            children: <Widget>[
              Spacer(),
              Text(
                dateTime.day.toString(),
                style: changeColorIfOutside(_R.getCalendarDayTextTheme(context))
                    .copyWith(decoration: TextDecoration.underline),
              ),
              Text(
                calendarInfo.occasions?.map((e) => e.name)?.join(', ') ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: changeColorIfOutside(
                    _R.getCalendarDayInfoTextTheme(context)),
              ),
              Spacer(),
            ],
          ),
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

    final key = GlobalKey();

    final contentWithCircle = () {
      if (calendarInfo.isStartSchoolYear || calendarInfo.isEndSchoolYear) {
        return Stack(
          key: key,
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
        return Container(
          key: key,
          child: contentWidget,
        );
      }
    }();

    final isSelected = () {
      if (_selectedDateStart == null || _selectedDateEnd == null) return false;
      if (_selectedDateStart.isAfter(_selectedDateEnd)) {
        return !removeTimeFrom(dateTime).isBefore(_selectedDateEnd) &&
            !removeTimeFrom(dateTime).isAfter(_selectedDateStart);
      } else {
        return !removeTimeFrom(dateTime).isBefore(_selectedDateStart) &&
            !removeTimeFrom(dateTime).isAfter(_selectedDateEnd);
      }
    }();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox box = key.currentContext.findRenderObject();
      _datePosition[box.localToGlobal(Offset.zero) & box.size] =
          removeTimeFrom(dateTime);
    });

    return GestureDetector(
      child: Container(
        color: isSelected ? _R.calendarSelectedColor : Colors.transparent,
        child: contentWithCircle,
      ),
      onTapDown: (_) => setState(() {
        _selectedDateStart = removeTimeFrom(dateTime);
        _selectedDateEnd = removeTimeFrom(dateTime);
      }),
      onTapUp: (_) {
        widget
            .onSelected(dateTime, _getPositionFromDateTime(dateTime).bottomLeft)
            .then((_) {
          setState(() {
            _selectedDateStart = null;
            _selectedDateEnd = null;
          });
        });
      },
      onTapCancel: () => setState(() {
        _selectedDateStart = null;
        _selectedDateEnd = null;
      }),
      onLongPressStart: widget.onRangeSelected == null
          ? null
          : (_) => setState(() {
                _selectedDateStart = removeTimeFrom(dateTime);
                _selectedDateEnd = removeTimeFrom(dateTime);
              }),
      onLongPressMoveUpdate: widget.onRangeSelected == null
          ? null
          : (details) => setState(() {
                final dateTime =
                    _getDateTimeFromPosition(details.globalPosition);
                if (dateTime == null) return;
                _selectedDateEnd = removeTimeFrom(dateTime);
              }),
      onLongPressEnd: widget.onRangeSelected == null
          ? null
          : (_) {
              if (removeTimeFrom(_selectedDateStart) ==
                  removeTimeFrom(_selectedDateEnd)) {
                widget
                    .onSelected(_selectedDateStart,
                        _getPositionFromDateTime(_selectedDateStart).bottomLeft)
                    .then((_) {
                  setState(() {
                    _selectedDateStart = null;
                    _selectedDateEnd = null;
                  });
                });
              } else {
                final range = () {
                  if (_selectedDateStart.isAfter(_selectedDateEnd)) {
                    return DateTimeRange(
                        start: _selectedDateEnd, end: _selectedDateStart);
                  } else {
                    return DateTimeRange(
                        start: _selectedDateStart, end: _selectedDateEnd);
                  }
                }();

                widget
                    .onRangeSelected(
                        range, _getPositionFromDateTime(range.end).bottomLeft)
                    .then((_) {
                  setState(() {
                    _selectedDateStart = null;
                    _selectedDateEnd = null;
                  });
                });
              }
            },
    );
  }
}
