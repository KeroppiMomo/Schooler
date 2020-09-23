import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:schooler/ui/assignment_screen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

AssignmentDayScreenResources _R = R.assignmentDayScreen;

class AssignmentsDayScreen extends StatefulWidget {
  final Function onSwitchView;

  AssignmentsDayScreen({Key key, this.onSwitchView}) : super(key: key);

  @override
  AssignmentsDayScreenState createState() => AssignmentsDayScreenState();
}

class AssignmentsDayScreenState extends State<AssignmentsDayScreen> {
  final now = DateTime.now();
  DateTime clippedNow;

  Map<DateTime, CalendarDayInfo> _calendar;
  DateTime _startSchoolYear;
  DateTime _endSchoolYear;
  ItemScrollController _controller;

  @override
  void initState() {
    super.initState();

    if (Settings().calendarType == CalendarType.week) {
      _calendar = Settings().weekConfig.getCalendar();
      _startSchoolYear = Settings().weekConfig.startSchoolYear;
      _endSchoolYear = Settings().weekConfig.endSchoolYear;
    } else if (Settings().calendarType == CalendarType.cycle) {
      _calendar = Settings().cycleConfig.getCalendar();
      _startSchoolYear = Settings().cycleConfig.startSchoolYear;
      _endSchoolYear = Settings().cycleConfig.endSchoolYear;
    } else {
      assert(false, 'Unexpected CalendarType value');
    }

    clippedNow = now;
    if (removeTimeFrom(now).isBefore(removeTimeFrom(_startSchoolYear))) {
      clippedNow = _startSchoolYear;
    } else if (removeTimeFrom(now).isAfter(removeTimeFrom(_endSchoolYear))) {
      clippedNow = _endSchoolYear;
    }

    _controller = ItemScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday(animated: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_R.appBarTitle),
        leading: IconButton(
          icon: Icon(_R.goToTodayIcon),
          tooltip: _R.goToTodayTooltip,
          onPressed: () => _scrollToToday(animated: true),
        ),
        actions: widget.onSwitchView == null
            ? null
            : [
                IconButton(
                  icon: Icon(Icons.list),
                  tooltip: _R.switchViewTooltip,
                  onPressed: widget.onSwitchView,
                ),
              ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        tooltip: _R.addFABTooltip,
        child: Icon(_R.addFABIcon),
        onPressed: () => _addAssignmentPressed(null),
      ),
      body: ValueListenableBuilder(
        valueListenable: Settings().assignmentListener,
        builder: (context, assignments, _) =>
            ScrollablePositionedList.separated(
          itemScrollController: _controller,
          // 1: end-start+1
          // 2: Start and end message
          itemCount: removeTimeFrom(_endSchoolYear)
                  .difference(removeTimeFrom(_startSchoolYear))
                  .inDays +
              1 +
              2,
          itemBuilder: (context, i) => _buildDay(
              removeTimeFrom(_startSchoolYear).add(Duration(days: i - 1))),
          separatorBuilder: (context, i) => Divider(
            height: _R.dayDividerHeight,
            indent: _R.dayDividerIndent,
          ),
        ),
      ),
    );
  }

  Widget _buildDay(DateTime date) {
    final dayInfo = _calendar[date];

    if (dayInfo == null) {
      DateTime startSchoolYear;
      if (Settings().calendarType == CalendarType.week) {
        startSchoolYear = Settings().weekConfig.startSchoolYear;
      } else if (Settings().calendarType == CalendarType.cycle) {
        startSchoolYear = Settings().cycleConfig.startSchoolYear;
      } else {
        assert(false, 'Unexpected CalendarType value');
      }

      return Padding(
        padding: _R.startEndMessagePadding,
        child: Center(
          child: Text(
            date.isBefore(startSchoolYear)
                ? _R.startReachedMessage
                : _R.endReachedMessage,
            style: _R.startEndMessageStyle(context),
          ),
        ),
      );
    }

    final isToday = date == DateTime.utc(now.year, now.month, now.day);
    final isHoliday = dayInfo.holidays != null;
    final isOccasion = dayInfo.occasions != null;

    final String dayDescription = () {
      final lines = <String>[];
      if (Settings().calendarType == CalendarType.week) {
        lines.add(_R.dayDayOfWeekFormat.format(date));
      } else if (Settings().calendarType == CalendarType.cycle) {
        lines.add(_R.dayDayOfWeekFormat.format(date));
        if (dayInfo.cycleDay != null && dayInfo.cycle != null) {
          lines.add('');
          lines.add(_R.dayCycleDayFormat(dayInfo.cycleDay));
          lines.add(_R.dayCycleFormat(dayInfo.cycle));
        }
      } else {
        assert(false, 'Unexpected CalendarType value');
        return '';
      }

      if (dayInfo.holidays != null && dayInfo.holidays.isNotEmpty) {
        for (final holiday in dayInfo.holidays) {
          lines.add('');
          lines.add(holiday.name);
        }
      }
      if (dayInfo.occasions != null) {
        for (final occasion in dayInfo.occasions) {
          lines.add('');
          lines.add(occasion.name);
        }
      }
      return lines.join('\n');
    }();

    final leftWidget = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        isToday
            ? Container(
                width: _R.todayCircleSize,
                height: _R.todayCircleSize,
                decoration: BoxDecoration(
                  color: isHoliday ? _R.holidayDayColor : _R.normalDayColor,
                  borderRadius: BorderRadius.circular(1000.0),
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: _R.dayTextStyle(context).copyWith(
                          color: _R.todayCircleTextColor,
                          decoration:
                              isOccasion ? _R.occasionTextDecoration : null,
                          fontWeight: _R.dayFontWeight,
                        ),
                  ),
                ),
              )
            : Text(
                date.day.toString(),
                style: Theme.of(context).textTheme.headline5.copyWith(
                      decoration: isOccasion ? _R.occasionTextDecoration : null,
                      color: isHoliday ? _R.holidayDayColor : _R.normalDayColor,
                      fontWeight: _R.dayFontWeight,
                    ),
              ),
        SizedBox(height: _R.dayDescriptionSpacing),
        Padding(
          padding: _R.dayDescriptionPadding,
          child: Text(
            dayDescription,
            textAlign: TextAlign.center,
            style: _R.dayDescriptionTextStyle(context).copyWith(
                  color: isHoliday ? _R.holidayDayColor : _R.normalDayColor,
                ),
          ),
        ),
      ],
    );

    final rightWidget = Column(
      children: [
        ...(Settings().assignments ?? [])
            .where((a) =>
                a.dueDate != null &&
                DateTime.utc(a.dueDate.year, a.dueDate.month, a.dueDate.day) ==
                    date)
            .map(_buildAssignment)
            .toList(),
        FlatButton(
          padding: _R.addAssignmentPadding,
          child: Row(children: [
            Container(
              width: _R.assignmentCheckboxColumnWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  _R.addAssignmentIcon,
                  color: _R.addAssignmentColor,
                ),
              ),
            ),
            Expanded(
                child: Text(
              _R.addAssignmentText,
              style: _R.addAssignmentTextStyle(context),
            )),
          ]),
          onPressed: () => _addAssignmentPressed(date),
        ),
      ],
    );

    final dayWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: _R.dayWidth, child: leftWidget),
        Expanded(child: rightWidget),
      ],
    );

    if (date.day == 1) {
      // First day of the month. Create a month header.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: _R.monthHeaderColor,
            child: Padding(
              padding: _R.monthHeaderPadding,
              child: Text(
                _R.monthHeaderFormat.format(date),
                style: _R.monthHeaderTextStyle(context),
              ),
            ),
            elevation: _R.monthHeaderElevation,
          ),
          SizedBox(height: _R.monthHeaderDaySpacing),
          dayWidget,
        ],
      );
    } else {
      return dayWidget;
    }
  }

  Widget _buildAssignment(Assignment assignment) {
    return InkWell(
      child: Padding(
        padding: _R.assignmentPadding,
        child: Table(
          columnWidths: {0: FixedColumnWidth(_R.assignmentCheckboxColumnWidth)},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: _R.assignmentCheckboxSize,
                  height: _R.assignmentCheckboxSize,
                  child: Checkbox(
                    value: assignment.isCompleted,
                    onChanged: (value) =>
                        _assignmentCompletionChanged(assignment, value),
                  ),
                ),
              ),
              Opacity(
                opacity: assignment.isCompleted
                    ? _R.assignmentCompletedOpacity
                    : 1.0,
                child: assignment.subject == null
                    ? Text(
                        assignment.name,
                        overflow: TextOverflow.ellipsis,
                        style: _R.assignmentTitleStyle(context),
                      )
                    : Row(children: [
                        SubjectBlock(
                          name: assignment.subject.name,
                          color: assignment.subject.color,
                        ),
                        SizedBox(width: _R.assignmentTitleSubjectSpacing),
                        Expanded(
                          child: Text(
                            assignment.name,
                            overflow: TextOverflow.ellipsis,
                            style: _R.assignmentTitleStyle(context),
                          ),
                        ),
                      ]),
              )
            ]),
            ...!assignment.withDueTime &&
                    (assignment.description == null ||
                        assignment.description == '')
                ? []
                : [
                    TableRow(children: [
                      Container(),
                      Opacity(
                        opacity: assignment.isCompleted
                            ? _R.assignmentCompletedOpacity
                            : 1.0,
                        child: Text.rich(
                          TextSpan(
                            text: assignment.withDueTime
                                ? _R.assignmentDueDateFormat
                                    .format(assignment.dueDate)
                                : '',
                            children: [
                              TextSpan(
                                text: assignment.description ?? '',
                                style:
                                    _R.assignmentDescriptionTextStyle(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ],
          ],
        ),
      ),
      onTap: () => _assignmentPressed(assignment),
    );
  }

  void _scrollToToday({@required bool animated}) async {
    final index = max(
        removeTimeFrom(now)
                .difference(removeTimeFrom(_startSchoolYear))
                .inDays +
            1,
        0);

    if (animated) {
      await _controller.scrollTo(
        index: index,
        alignment: _R.goToTodayAlignment,
        duration: _R.goToTodayDuration,
        curve: _R.goToTodayCurve,
      );
    } else {
      _controller.jumpTo(index: index, alignment: _R.goToTodayAlignment);
    }
  }

  void _assignmentCompletionChanged(Assignment assignment, bool newValue) {
    setState(() {
      assignment.isCompleted = newValue;
      Settings().assignmentListener.notifyListeners();
      Settings().saveSettings();
    });
  }

  /// When "Add Assignment" buttons are pressed.
  ///
  /// If `date == null`, the FAB is pressed.
  /// If `date != null`, the "Add Assignment" button in the day widget is pressed.
  void _addAssignmentPressed(DateTime date) {
    final assignment = Assignment(
      isCompleted: false,
      name: '',
      description: '',
      subject: null,
      dueDate: date,
      withDueTime: false,
      notes: '',
    );
    Settings().assignments.add(assignment);
    Settings().assignmentListener.notifyListeners();
    Settings().saveSettings();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AssignmentScreen(assignment: assignment),
    ));
  }

  void _assignmentPressed(Assignment assignment) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AssignmentScreen(assignment: assignment),
    ));
  }
}
