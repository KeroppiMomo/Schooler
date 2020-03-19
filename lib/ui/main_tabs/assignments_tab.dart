import 'package:flutter/material.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:schooler/ui/assignment_screen.dart';

AssignmentsTabResources _R = R.assignmentTab;

class AssignmentsTab extends StatefulWidget {
  @override
  AssignmentsTabState createState() => AssignmentsTabState();
}

class AssignmentsTabState extends State<AssignmentsTab> {
  final now = DateTime.now();

  Map<DateTime, CalendarDayInfo> _calendar;
  InfiniteScrollController _controller;

  @override
  void initState() {
    super.initState();

    final testAssignments = [
      Assignment(
        name: 'Assignment Tab Assignments',
        description: 'Wow',
        subject: null,
        dueDate: DateTime(2019, 12, 31),
        withDueTime: false,
      ),
      Assignment(
        name: 'Exercise 4A',
        description: 'P.19',
        subject: Subject('Maths'),
        dueDate: DateTime(2020, 1, 1),
        withDueTime: false,
      ),
      Assignment(
        name: 'Maths Assignment',
        description: '4A 1-20, Draw Diagram',
        subject: Subject('Maths'),
        dueDate: DateTime(2020, 1, 1, 15, 0),
        withDueTime: true,
      ),
      Assignment(
        name: 'Upload File',
        description: 'History Worksheet',
        subject: null,
        dueDate: DateTime(2020, 1, 7, 12, 00),
        withDueTime: true,
      ),
      Assignment(
        name: 'Poem Reading',
        description: 'The Great Poem',
        subject: Subject('English'),
        dueDate: DateTime(2020, 1, 2, 12, 00),
        withDueTime: true,
      ),
      Assignment(
        name: 'Writing',
        subject: Subject('English'),
        dueDate: null,
        withDueTime: false,
      ),
      Assignment(
        name: 'Reply Email',
        dueDate: DateTime(2020, 1, 3, 23, 59),
        withDueTime: true,
      ),
      Assignment(
        name: 'Experiment Report',
        isCompleted: false,
        subject: Subject('Chemistry', color: Colors.yellow),
        dueDate: DateTime(2020, 1, 10),
        withDueTime: false,
      ),
      Assignment(
        name: 'Long long long long long long long',
        isCompleted: false,
        subject: null,
        dueDate: DateTime(2020, 1, 8),
        withDueTime: false,
      ),
      Assignment(
        name: 'Book Report',
        isCompleted: false,
        subject: Subject('Chinese', color: Colors.orange),
        dueDate: DateTime(2020, 1, 9),
        withDueTime: false,
      ),
    ];
    Settings().assignments = testAssignments;

    _calendar = () {
      if (Settings().calendarType == CalendarType.week) {
        return Settings().weekConfig.getCalendar();
      } else if (Settings().calendarType == CalendarType.cycle) {
        return Settings().cycleConfig.getCalendar();
      } else {
        assert(false, 'Unexpected CalendarType value');
        return null;
      }
    }();

    _controller = InfiniteScrollController(initialScrollOffset: _R.todayOffset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_R.appBarTitle),
        actions: [
          IconButton(
            icon: Icon(_R.goToTodayIcon),
            tooltip: _R.goToTodayTooltip,
            onPressed: () => _controller.animateTo(
              _R.todayOffset,
              duration: _R.goToTodayDuration,
              curve: _R.goToTodayCurve,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: _R.addFABTooltip,
        child: Icon(_R.addFABIcon),
        onPressed: () => _addAssignmentPressed(null),
      ),
      body: InfiniteListView.separated(
        controller: _controller,
        itemBuilder: (context, i) => _buildDay(
            DateTime.utc(now.year, now.month, now.day).add(Duration(days: i))),
        separatorBuilder: (context, i) => Divider(
          height: _R.dayDividerHeight,
          indent: _R.dayDividerIndent,
        ),
      ),
    );
  }

  Widget _buildDay(DateTime date) {
    final dayInfo = _calendar[date];

    if (dayInfo == null) {
      DateTime startSchoolYear, endSchoolYear;
      if (Settings().calendarType == CalendarType.week) {
        startSchoolYear = Settings().weekConfig.startSchoolYear;
        endSchoolYear = Settings().weekConfig.endSchoolYear;
      } else if (Settings().calendarType == CalendarType.cycle) {
        startSchoolYear = Settings().cycleConfig.startSchoolYear;
        endSchoolYear = Settings().cycleConfig.endSchoolYear;
      } else {
        assert(false, 'Unexpected CalendarType value');
      }

      if (date.isBefore(startSchoolYear)) {
        return Column(children: [
          Container(height: 1000000.0),
          Text(
            _R.startReachedMessage,
            style: _R.startEndMessageStyle(context),
          ),
        ]);
      } else {
        return Column(children: [
          Text(
            _R.endReachedMessage,
            style: _R.startEndMessageStyle(context),
          ),
          Container(height: 1000000.0),
        ]);
      }
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

      if (dayInfo.holidays != null && dayInfo.holidays != '') {
        for (final holiday in dayInfo.holidays.split(', ')) {
          lines.add('');
          lines.add(holiday);
        }
      }
      if (dayInfo.occasions != null) {
        for (final occasion in dayInfo.occasions.split(', ')) {
          lines.add('');
          lines.add(occasion);
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

  void _assignmentCompletionChanged(Assignment assignment, bool newValue) {
    setState(() => assignment.isCompleted = newValue);
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
