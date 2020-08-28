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

AssignmentScreenResources _R = R.assignmentScreen;

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
        title: Text(_R.appBarTitle),
        leading: BackButton(
          onPressed: _onBackPressed,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Delete Assignment',
            onPressed: _deletePressed,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Settings().assignmentListener,
        builder: (context, value, _) => ListView(
          padding: _R.listViewPadding,
          children: [
            Table(
              columnWidths: {0: FixedColumnWidth(_R.iconColumnWidth)},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                _buildRow(
                  // Title and isCompleted
                  leading: SizedBox(
                    width: _R.checkboxSize,
                    height: _R.checkboxSize,
                    child: Checkbox(
                      value: widget.assignment.isCompleted,
                      onChanged: _isCompletedTapped,
                    ),
                  ),
                  child: TextField(
                    style: Theme.of(context).textTheme.headline5,
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: _R.titleHintText,
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
                      hintText: _R.descriptionHintText,
                      isDense: true,
                    ),
                    onChanged: _descriptionOnChanged,
                  ),
                ),
                _buildRow(
                  // Spacing
                  leading: SizedBox(height: _R.descriptionSubjectSpacing),
                  child: Container(),
                ),
                _buildRow(
                  // Select Subject
                  leading: Icon(
                    _R.subjectIcon,
                    color: _R.leftIconColor,
                  ),
                  child: InkWell(
                    child: widget.assignment.subject == null
                        ? Container(
                            height: _R.subjectRow,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: _R.subjectPlaceholderPadding,
                                child: Text(
                                  _R.subjectPlaceholder,
                                  style: _R.placeholderStyle(context),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: _R.subjectRow,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: SubjectBlock(
                                    name: widget.assignment.subject.name,
                                    color: widget.assignment.subject.color,
                                  ),
                                ),
                                SizedBox(width: _R.subjectRowSpacing),
                                Icon(
                                  _R.editIcon,
                                  color: _R.rightIconColor,
                                ),
                                SizedBox(width: _R.subjectRowSpacing),
                                InkWell(
                                  child: Icon(
                                    _R.subjectRemoveIcon,
                                    color: _R.rightIconColor,
                                  ),
                                  onTap: _subjectRemoved,
                                ),
                              ],
                            ),
                          ),
                    onTap: _subjectTapped,
                  ),
                ),
                _buildRow(
                  // Spacing
                  leading: SizedBox(height: _R.subjectDueTypeSpacing),
                  child: Container(),
                ),
                _buildRow(
                  // Select withTime
                  leading: Container(),
                  child: Wrap(
                    runSpacing: _R.dueTypeRunSpacing,
                    spacing: _R.dueTypeSpacing,
                    children: <Widget>[
                      ChoiceChip(
                        label: Text(_R.dueTypeNoDueDate),
                        selected: widget.assignment.dueDate == null,
                        onSelected: (value) {
                          if (value) _dueDateTypeChanged(null);
                        },
                      ),
                      ChoiceChip(
                        label: Text(_R.dueTypeDueDate),
                        selected: widget.assignment.dueDate != null &&
                            !widget.assignment.withDueTime,
                        onSelected: (value) {
                          if (value) _dueDateTypeChanged(false);
                        },
                      ),
                      ChoiceChip(
                        label: Text(_R.dueTypeDueTime),
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
                    duration: _R.dueDateAnimationDuration,
                    child: _dueDateRowLeading,
                  ),
                  child: AnimatedSwitcher(
                    duration: _R.dueDateAnimationDuration,
                    child: _dueDateRowChild,
                  ),
                ),
                _buildRow(
                  leading: Container(),
                  child: SizedBox(height: _R.dueDateNotesSpacing),
                ),
                _buildRow(
                  leading: Icon(
                    _R.notesIcon,
                    color: _R.leftIconColor,
                  ),
                  child: InkWell(
                    onTap: _notesTapped,
                    child: Padding(
                      padding: _R.notesPadding,
                      child: widget.assignment.notes == null ||
                              widget.assignment.notes == ''
                          ? Text(_R.notesPlaceholder,
                              style: _R.placeholderStyle(context))
                          : Builder(
                              builder: (context) => Linkify(
                                onOpen: (link) =>
                                    _notesURLTapped(context, link),
                                text: widget.assignment.notes,
                                options: LinkifyOptions(humanize: false),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shared with ReminderScreen
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
          Icon(_R.dueDateIcon, key: ValueKey(false), color: Colors.transparent);
      _dueDateRowChild = Container(height: _R.dueDateRowHeight);
    } else if (widget.assignment.withDueTime) {
      _dueDateRowLeading =
          Icon(_R.dueDateIcon, key: ValueKey(true), color: _R.leftIconColor);
      _dueDateRowChild = Container(
        key: ValueKey(true),
        height: _R.dueDateRowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                child: Row(
                  children: [
                    Padding(
                      padding: _R.dueDateInkWellPadding,
                      child: Text(
                        _R.dueDateFormat.format(widget.assignment.dueDate),
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
                  padding: _R.dueDateInkWellPadding,
                  child:
                      Text(_R.dueTimeFormat.format(widget.assignment.dueDate)),
                ),
                SizedBox(width: _R.dueDateEditSpacing),
                Icon(_R.editIcon, color: _R.rightIconColor),
              ]),
              onTap: _dueTimeTapped,
            ),
          ],
        ),
      );
    } else {
      _dueDateRowLeading =
          Icon(_R.dueDateIcon, key: ValueKey(true), color: _R.leftIconColor);
      _dueDateRowChild = Container(
        key: ValueKey(false),
        height: _R.dueDateRowHeight,
        child: InkWell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: _R.dueDateInkWellPadding,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _R.dueDateFormat.format(widget.assignment.dueDate),
                  ),
                ),
              ),
              SizedBox(width: _R.dueDateEditSpacing),
              Icon(_R.editIcon, color: _R.rightIconColor),
            ],
          ),
          onTap: _dueDateTapped,
        ),
      );
    }
  }

  void _nameOnChanged(String newValue) {
    widget.assignment.name = newValue;
    _setDueDateRow();
    Settings().assignmentListener.notifyListeners();
    Settings().saveSettings();
  }

  void _descriptionOnChanged(String newValue) {
    widget.assignment.description = newValue;
    _setDueDateRow();
    Settings().assignmentListener.notifyListeners();
    Settings().saveSettings();
  }

  void _subjectTapped() {
    SuggestionTextField.showSubjectPicker(
      context,
      subjectIcon: _R.subjectIcon,
      minItemForListView: _R.subjectMinItemForListView,
      listViewHeight: _R.subjectListViewHeight,
      onDone: (subject) {
        widget.assignment.subject = subject;
        _setDueDateRow();
        Settings().assignmentListener.notifyListeners();
        Settings().saveSettings();
      },
    );
  }

  void _subjectRemoved() {
    widget.assignment.subject = null;
    _setDueDateRow();
    Settings().assignmentListener.notifyListeners();
    Settings().saveSettings();
  }

  void _isCompletedTapped(bool newValue) {
    widget.assignment.isCompleted = newValue;
    _setDueDateRow();
    Settings().assignmentListener.notifyListeners();
    Settings().saveSettings();
  }

  /// Called when the due date type (i.e. no due date, due date or due time) is changed.
  /// withTime == true:   Due Time
  /// withTime == false:  Due Date
  /// withTime == null:   No Due Date
  void _dueDateTypeChanged(bool withTime) {
    widget.assignment.dueDate = _dueDateAccurate;
    if (withTime == null)
      widget.assignment.dueDate = null;
    else
      widget.assignment.withDueTime = withTime;
    _setDueDateRow();
    Settings().assignmentListener.notifyListeners();
    Settings().saveSettings();
  }

  void _dueDateTapped() {
    void dateChosen(DateTime date) {
      Navigator.pop(context);

      final dueDate = widget.assignment.dueDate;
      widget.assignment.dueDate = DateTime(
          date.year, date.month, date.day, dueDate.hour, dueDate.minute);
      _dueDateAccurate = widget.assignment.dueDate;
      _setDueDateRow();
      Settings().assignmentListener.notifyListeners();
      Settings().saveSettings();
    }

    SuggestionTextField.showDatePicker(
      context,
      subject: widget.assignment.subject,
      onDone: dateChosen,
    );
  }

  void _dueTimeTapped() {
    DatePicker.showPicker(
      context,
      showTitleActions: true,
      pickerModel: TimePicker.normal(currentTime: widget.assignment.dueDate),
      onConfirm: (DateTime time) {
        final dueDate = widget.assignment.dueDate;
        widget.assignment.dueDate = DateTime(
            dueDate.year, dueDate.month, dueDate.day, time.hour, time.minute);
        _dueDateAccurate = widget.assignment.dueDate;
        _setDueDateRow();
        Settings().assignmentListener.notifyListeners();
        Settings().saveSettings();
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
        content: Text(_R.getNotesURLError(link.url)),
      ));
    }
  }

  void _notesTapped() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditTextScreen(
              title: _R.notesEditTextTitle,
              value: widget.assignment.notes ?? '',
              maxLines: null,
              onDone: (text) {
                widget.assignment.notes = text;
                _setDueDateRow();
                Settings().assignmentListener.notifyListeners();
                Settings().saveSettings();
              },
            )));
  }

  void _deletePressed() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Assignment?'),
        content: Text('This action cannot be undone.'),
        actions: <Widget>[
          FlatButton(
            child: Text('CANCEL'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text('DELETE'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ).then((shouldDelete) {
      // Not `if (shouldDelete)` because it might be null
      if (shouldDelete == true) {
        Settings().assignments.remove(widget.assignment);
        Settings().assignmentListener.notifyListeners();
        Settings().saveSettings();

        // Go to previous page
        Navigator.pop(context);
      }
    });
  }

  void _onBackPressed() {
    bool isEmptyOrNull(String str) => str == null || str == '';
    if (isEmptyOrNull(widget.assignment.name) &&
        isEmptyOrNull(widget.assignment.description) &&
        isEmptyOrNull(widget.assignment.notes) &&
        widget.assignment.subject == null) {
      // Assignment is considered empty. Remove it.
      Settings().assignments.remove(widget.assignment);
      Settings().assignmentListener.notifyListeners();
      Settings().saveSettings();
    }
    Navigator.pop(context);
  }
}
