import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/edit_text_screen.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:schooler/ui/suggestion_text_field.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart'
    show DatePicker;
import 'package:schooler/ui/time_picker.dart';
import 'package:schooler/ui/cycle_calendar.dart';
import 'package:schooler/ui/week_calendar.dart';

class AssignmentScreen extends StatefulWidget {
  final Assignment assignment;

  AssignmentScreen({Key key, this.assignment}) : super(key: key);

  @override
  AssignmentScreenState createState() => AssignmentScreenState();
}

class AssignmentScreenState extends State<AssignmentScreen> {
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  Widget _dueDateRowChild;
  Widget _dueDateRowLeading;

  /// The most accurate due date editted by user.
  ///
  /// When the due date type is switched from 'Due Time' to 'Due Date' back
  /// to 'Due Time', the displayed due time should be the same as the original
  /// one. The same thing should happen when 'Due Date' is switched to 'No Due
  /// Date' and back to 'Due Date'. The most accurate due time is kept here.
  DateTime _dueDateAccurate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.assignment.name);
    _descriptionController =
        TextEditingController(text: widget.assignment.description);

    if (widget.assignment.dueDate == null) {
      _dueDateAccurate = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59);
    } else if (widget.assignment.withDueTime) {
      _dueDateAccurate = widget.assignment.dueDate;
    } else {
      final dueDate = widget.assignment.dueDate;
      _dueDateAccurate =
          DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59);
    }

    _setDueDateRow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        children: [
          Table(
            columnWidths: {0: FixedColumnWidth(48.0)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _buildRow(
                // Title and isCompleted
                leading: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: Checkbox(
                    value: widget.assignment.isCompleted,
                    onChanged: _isCompletedTapped,
                  ),
                ),
                child: TextField(
                  style: Theme.of(context).textTheme.headline5,
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                  ),
                  onChanged: _nameOnChanged,
                ),
              ),
              _buildRow(
                // Description
                leading: Container(),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Add Description',
                    isDense: true,
                  ),
                  onChanged: _descriptionOnChanged,
                ),
              ),
              _buildRow(
                // Spacing
                leading: SizedBox(height: 32.0),
                child: Container(),
              ),
              _buildRow(
                // Select Subject
                leading: Icon(
                  Icons.book,
                  color: Colors.black54,
                ),
                child: InkWell(
                  child: widget.assignment.subject == null
                      ? Container(
                          height: 32.0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                'Add Subject',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(color: Colors.black54),
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: SubjectBlock(
                                name: widget.assignment.subject.name,
                                color: widget.assignment.subject.color,
                              ),
                            ),
                            SizedBox(width: 4.0),
                            Icon(
                              Icons.edit,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4.0),
                            InkWell(
                              child: Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onTap: _subjectRemoved,
                            ),
                          ],
                        ),
                  onTap: _subjectTapped,
                ),
              ),
              _buildRow(
                // Spacing
                leading: SizedBox(height: 16.0),
                child: Container(),
              ),
              _buildRow(
                // Select withTime
                leading: Container(),
                child: Wrap(
                  runSpacing: -8.0,
                  spacing: 4.0,
                  children: <Widget>[
                    ChoiceChip(
                      label: Text('No Due Date'),
                      selected: widget.assignment.dueDate == null,
                      onSelected: (value) {
                        if (value) _dueDateTypeChanged(null);
                      },
                    ),
                    ChoiceChip(
                      label: Text('Due Date'),
                      selected: widget.assignment.dueDate != null &&
                          !widget.assignment.withDueTime,
                      onSelected: (value) {
                        if (value) _dueDateTypeChanged(false);
                      },
                    ),
                    ChoiceChip(
                      label: Text('Due Time'),
                      selected: widget.assignment.dueDate != null &&
                          widget.assignment.withDueTime,
                      onSelected: (value) {
                        if (value) _dueDateTypeChanged(true);
                      },
                    ),
                  ],
                ),
              ),
              _buildRow(
                leading: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: _dueDateRowLeading,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: _dueDateRowChild,
                ),
              ),
              _buildRow(
                leading: Container(),
                child: SizedBox(height: 16.0),
              ),
              _buildRow(
                leading: Icon(Icons.subject, color: Colors.black54),
                child: InkWell(
                  onTap: _notesTapped,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                    child: widget.assignment.notes == null ||
                            widget.assignment.notes == ''
                        ? Text('Add Notes', style: R.placeholderTextStyle)
                        : Builder(
                            builder: (context) => Linkify(
                              onOpen: (link) => _notesURLTapped(context, link),
                              text: widget.assignment.notes,
                              options: LinkifyOptions(humanize: false),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  TableRow _buildRow({Widget leading, Widget child}) {
    return TableRow(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: leading,
      ),
      child,
    ]);
  }

  void _setDueDateRow() {
    if (widget.assignment.dueDate == null) {
      _dueDateRowLeading =
          Icon(Icons.today, key: ValueKey(false), color: Colors.transparent);
      _dueDateRowChild = Container(height: 32.0);
    } else if (widget.assignment.withDueTime) {
      _dueDateRowLeading =
          Icon(Icons.today, key: ValueKey(true), color: Colors.black54);
      _dueDateRowChild = Container(
        key: ValueKey(true),
        height: 32.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        DateFormat('dd MMM').format(widget.assignment.dueDate),
                      ),
                    ),
                  ],
                ),
                onTap: _dueDateTapped,
              ),
            ),
            InkWell(
              child: Row(children: [
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                      DateFormat('HH:mm').format(widget.assignment.dueDate)),
                ),
                SizedBox(width: 4.0),
                Icon(Icons.edit, color: Colors.grey),
              ]),
              onTap: _dueTimeTapped,
            ),
          ],
        ),
      );
    } else {
      _dueDateRowLeading =
          Icon(Icons.today, key: ValueKey(true), color: Colors.black54);
      _dueDateRowChild = Container(
        key: ValueKey(false),
        height: 32.0,
        child: InkWell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat('dd MMM').format(widget.assignment.dueDate),
                  ),
                ),
              ),
              SizedBox(width: 4.0),
              Icon(Icons.edit, color: Colors.grey),
            ],
          ),
          onTap: _dueDateTapped,
        ),
      );
    }
  }

  void _nameOnChanged(String newValue) {
    setState(() => widget.assignment.name = newValue);
  }

  void _descriptionOnChanged(String newValue) {
    setState(() => widget.assignment.description = newValue);
  }

  void _subjectTapped() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SuggestionTextField(
            minItemForListView: 4,
            listViewHeight: 195.0,
            curValue: '',
            suggestionCallback: (pattern) {
              final List<String> suggestions = [];
              for (final subject in Settings().subjects) {
                if (subject.name.length < pattern.length) continue;
                if (subject.name.substring(0, pattern.length).toLowerCase() ==
                    pattern.toLowerCase()) {
                  suggestions.add(subject.name);
                }
              }
              return suggestions;
            },
            suggestionBuilder: (context, name, onSubmit) {
              final subject = Settings()
                  .subjects
                  .firstWhere((subject) => subject.name == name);
              return ListTile(
                leading: Icon(Icons.book, color: subject.color),
                title: Text(subject.name),
                onTap: onSubmit,
              );
            },
            onDone: (name) {
              setState(() {
                final subject = Settings().subjects.firstWhere(
                    (subject) => subject.name == name,
                    orElse: () => Subject(name));
                widget.assignment.subject = subject;
              });
            },
          ),
        ),
      ),
    );
  }

  void _subjectRemoved() {
    setState(() => widget.assignment.subject = null);
  }

  void _isCompletedTapped(bool newValue) {
    setState(() => widget.assignment.isCompleted = newValue);
  }

  /// Called when the due date type (i.e. no due date, due date or due time) is changed.
  /// withTime == true:   Due Time
  /// withTime == false:  Due Date
  /// withTime == null:   No Due Date
  void _dueDateTypeChanged(bool withTime) {
    setState(() {
      widget.assignment.dueDate = _dueDateAccurate;
      if (withTime == null)
        widget.assignment.dueDate = null;
      else
        widget.assignment.withDueTime = withTime;

      _setDueDateRow();
    });
  }

  void _dueDateTapped() {
    void dateChosen(DateTime date) {
      Navigator.pop(context);

      setState(() {
        final dueDate = widget.assignment.dueDate;
        widget.assignment.dueDate = DateTime(
            date.year, date.month, date.day, dueDate.hour, dueDate.minute);
        _dueDateAccurate = widget.assignment.dueDate;
        _setDueDateRow();
      });
    }

    final monday =
        DateTime.now().add(Duration(days: 8 - DateTime.now().weekday));

    final subjectSessionDate = () {
      if (widget.assignment.subject == null) return null;

      final Map<DateTime, CalendarDayInfo> calendar = () {
        if (Settings().calendarType == CalendarType.week)
          return Settings().weekConfig.getCalendar();
        if (Settings().calendarType == CalendarType.cycle)
          return Settings().cycleConfig.getCalendar();
        else {
          assert(false, 'Unknown CalendarType value');
          return {};
        }
      }();

      for (DateTime date = removeTimeFrom(DateTime.now());
          calendar[date] != null;
          date = date.add(Duration(days: 1))) {
        final dayInfo = calendar[date];

        final timetableDay = () {
          final existingDays = Settings().timetable.days;
          for (final holiday in dayInfo.holidays?.split(', ') ?? []) {
            final day = TimetableOccasionDay(holiday);
            if (existingDays.contains(day)) return day;
          }
          for (final occasion in dayInfo.holidays?.split(', ') ?? []) {
            final day = TimetableOccasionDay(occasion);
            if (existingDays.contains(day)) return day;
          }

          if (Settings().calendarType == CalendarType.week) {
            final day = TimetableWeekDay(date.weekday);
            if (existingDays.contains(day)) return day;
          } else if (Settings().calendarType == CalendarType.cycle) {
            if (dayInfo.cycleDay != null) {
              final day = TimetableCycleDay(int.parse(dayInfo.cycleDay));
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

        if (sessions
            .any((session) => session.name == widget.assignment.subject.name)) {
          return date;
        }
      }

      return null;
    }();

    final calendarController = CalendarController();

    final calendarWidget = () {
      if (Settings().calendarType == CalendarType.week) {
        return WeekCalendar(
          calendarController: calendarController,
          weekConfig: Settings().weekConfig,
          calendarInfo: Settings().weekConfig.getCalendar(),
          onSelected: dateChosen,
        );
      } else if (Settings().calendarType == CalendarType.cycle) {
        return CycleCalendar(
          calendarController: calendarController,
          cycleConfig: Settings().cycleConfig,
          calendarInfo: Settings().cycleConfig.getCalendar(),
          onSelected: dateChosen,
        );
      } else {
        assert(false, 'Unexpected CalendarType value');
        return null;
      }
    }();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                  pressedOpacity: 0.3,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Cancel',
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 16.0),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              calendarWidget,
              Divider(),
              ListTile(
                leading: Icon(Icons.today),
                title: Text('Today'),
                subtitle: Text(DateFormat('dd MMM').format(DateTime.now())),
                trailing: Icon(Icons.navigate_next),
                onTap: () => dateChosen(DateTime.now()),
              ),
              ListTile(
                leading: Icon(Icons.today),
                title: Text('Tomorrow'),
                subtitle: Text(DateFormat('dd MMM')
                    .format(DateTime.now().add(Duration(days: 1)))),
                trailing: Icon(Icons.navigate_next),
                onTap: () => dateChosen(DateTime.now().add(Duration(days: 1))),
              ),
              ListTile(
                leading: Icon(Icons.today),
                title: Text('Monday'),
                subtitle: Text(DateFormat('dd MMM').format(monday)),
                trailing: Icon(Icons.navigate_next),
                onTap: () => dateChosen(monday),
              ),
              ...subjectSessionDate == null
                  ? []
                  : [
                      ListTile(
                        leading: Icon(Icons.today),
                        title: Text(
                            'Next ${widget.assignment.subject.name} Session'),
                        subtitle: Text(
                            DateFormat('dd MMM').format(subjectSessionDate)),
                        trailing: Icon(Icons.navigate_next),
                        onTap: () => dateChosen(subjectSessionDate),
                      )
                    ],
            ],
          ),
        ),
      ),
    );
  }

  void _dueTimeTapped() {
    DatePicker.showPicker(
      context,
      showTitleActions: true,
      pickerModel: TimePicker(currentTime: widget.assignment.dueDate),
      onConfirm: (DateTime time) {
        setState(() {
          final dueDate = widget.assignment.dueDate;
          widget.assignment.dueDate = DateTime(
              dueDate.year, dueDate.month, dueDate.day, time.hour, time.minute);
          _dueDateAccurate = widget.assignment.dueDate;
          _setDueDateRow();
        });
      },
    );
  }

  void _notesURLTapped(BuildContext context, LinkableElement link) async {
    try {
      if (await canLaunch(link.url)) {
        await launch(link.url);
      } else {
        throw Exception();
      }
    } catch (e) {
      print(e);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
            'Failed to open ${link.url}. Check whether the URL is correct.'),
      ));
    }
  }

  void _notesTapped() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditTextScreen(
              title: 'Notes',
              value: widget.assignment.notes ?? '',
              maxLines: null,
              onDone: (text) => setState(() => widget.assignment.notes = text),
            )));
  }
}
