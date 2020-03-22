import 'package:flutter/material.dart';
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/ui/assignment_screen.dart';
import 'package:schooler/ui/main_tabs/wwidgets/wwidget.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:tuple/tuple.dart';
import 'dart:math';
import 'dart:async';

AssignmentWWidgetResources _R = R.assignmentWWidget;

class AssignmentsWWidget extends StatefulWidget {
  final DateTime now;

  AssignmentsWWidget({Key key, @required this.now}) : super(key: key);

  @override
  AssignmentsWWidgetState createState() => AssignmentsWWidgetState();
}

class AssignmentsWWidgetState extends State<AssignmentsWWidget> {
  /// The currently shown assignments.
  List<Assignment> _shownAssignments;

  GlobalKey<AnimatedListState> _listKey;

  /// The timers of the delays of removing assignments, and the
  /// shown assignments after the removal.
  ///
  /// When a assignment is completed, the animation is played
  /// after one second. The delay is kept track of by the timer
  /// in this variable, along with the assignment which has
  /// been completed.
  ///
  /// To handle multiple removal pending at the same time, the
  /// shown assignments after each removal of assignment are
  /// stored. This is because each list of shown assignments is
  /// required to build the `AniamtedList` after the removal but
  /// before the next removal.
  ///
  /// `List<MapEntry>` is used instaed of a regular `Map` because
  /// a `identical` comparison (two assignments are the same
  /// reference) is needed to retrieve the correct value. If
  /// `==` is used, assignments with same property values are not
  /// distinguished.
  List<MapEntry<Assignment, Tuple2<Timer, List<Assignment>>>> _removeDelayInfo =
      [];

  /// Whether the list update is triggered inside the wwidget.
  ///
  /// This is used when the [ValueListenableBuilder] is rebuilding
  /// due to changes to assignments, If the change is trigerred in
  /// the wwidget, updating the shown assignment list is controlled
  /// in other part of the class (`_assignmentCompletionChanged`),
  /// so the list should not be updated there. If the change is
  /// triggered in other parts of the app, the shown assignment list
  /// should be updated (without animation).
  ///
  /// Therefore, if the assignment list is changed in this wwidget,
  /// this variable should be set to `true`. This variable should be
  /// set back to `false` once the build is completed. If this
  /// variable is `false` before the build, the shown assignment list
  /// should be updated.
  bool _isInternalUpdating = false;

  @override
  void initState() {
    super.initState();
    final testAssignments = [
      Assignment(
        name: 'Exercise 4A',
        subject: Subject('Maths'),
        dueDate: DateTime(2020, 1, 1),
        withDueTime: false,
      ),
      Assignment(
        name: 'Upload File',
        subject: null,
        dueDate: DateTime(2020, 1, 7, 12, 00),
        withDueTime: true,
      ),
      Assignment(
        name: 'Poem Reading',
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
    _shownAssignments = _getShownAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return WWidget(
      title: _R.wwidgetTitle,
      icon: _R.wwidgetIcon,
      contentPadding: _R.wwidgetPadding,
      child: ValueListenableBuilder(
        valueListenable: Settings().assignmentListener,
        builder: (context, value, _) {
          // Determine whether the change is from the wwidget or from other parts of the app
          // See documentation of `_isInternalUpdating`.
          if (_isInternalUpdating) {
            // The change is from this wwidget. The `_shownAssignments` update mechanism is handled elsewhere.
            _isInternalUpdating = false;
          } else {
            // The change is from other parts of the app.

            // Change key to notify Flutter to show the new [AnimatedList]
            _listKey = GlobalKey();

            // Update the shown assignments
            _shownAssignments = _getShownAssignments();

            // Cancel removal timer and delete delays
            for (int i = _removeDelayInfo.length - 1; i >= 0; i--) {
              _removeDelayInfo[i].value.item1.cancel();
              _removeDelayInfo.removeAt(i);
            }
          }

          return AnimatedList(
            // Use AnimatedList because it handles inserting and removing items
            key: _listKey,
            physics: NeverScrollableScrollPhysics(), // Not allow to scroll
            shrinkWrap: true, // Use minimum space
            initialItemCount: max(_shownAssignments.length, 1) + 2,
            // When length == 0, the empty messge is shown, so min = 1. +2 is the "Add" and "View" buttons.
            itemBuilder: (context, i, animation) {
              final noOfAssignments = max(_shownAssignments.length,
                  1); // See comment on initialItemCount
              if (i == noOfAssignments) {
                return FlatButton.icon(
                  icon: Icon(_R.addAssignmentIcon),
                  label: Text(_R.addAssignmentText),
                  onPressed: _addAssignmentPressed,
                );
              } else if (i == noOfAssignments + 1) {
                return FlatButton.icon(
                  icon: Icon(_R.viewAssignmentsIcon),
                  label: Text(_R.getViewAssignmentsText(
                      ((Settings().assignments ?? [])
                              .where((a) => !a.isCompleted))
                          .length)),
                  onPressed: _viewAssignmentsPressed,
                );
              } else {
                if (_shownAssignments.length == 0) {
                  return Padding(
                    padding: _R.completedTextPadding,
                    child: Text(
                      _R.completedText,
                      textAlign: TextAlign.center,
                      style: _R.getCompletedTextStyle(context),
                    ),
                  );
                } else {
                  return _buildAssignment(
                      context, i, _shownAssignments[i], animation);
                }
              }
            },
          );
        },
      ),
      onSettingsPressed: _settingsPressed,
    );
  }

  Widget _buildAssignment(BuildContext context, int assignmentIndex,
      Assignment assignment, Animation animation) {
    final Color dueColor = () {
      // Three colors:
      // Expired                          - Red
      // Due in one day                   - Primary Color
      // Due in the future / No due date  - Grey
      if (assignment.dueDate == null) return _R.dueColorFuture;
      if (assignment.withDueTime) {
        if (assignment.dueDate.compareTo(widget.now) < 0) {
          return _R.dueColorExpired;
        } else if (assignment.dueDate.difference(widget.now).inHours <= 24) {
          return _R.getDueColorOneDay(context);
        } else {
          return _R.dueColorFuture;
        }
      } else {
        final nowDateOnly =
            DateTime.utc(widget.now.year, widget.now.month, widget.now.day);
        final dueDateOnly = DateTime.utc(assignment.dueDate.year,
            assignment.dueDate.month, assignment.dueDate.day);
        if (dueDateOnly.compareTo(nowDateOnly) < 0) {
          return _R.dueColorExpired;
        } else if (dueDateOnly.difference(nowDateOnly).inDays <= 1) {
          return _R.getDueColorOneDay(context);
        } else {
          return _R.dueColorFuture;
        }
      }
    }();
    final assignmentWidget = InkWell(
      child: Padding(
        padding: _R.assignmentPadding,
        child: Table(
          columnWidths: {0: FixedColumnWidth(_R.checkboxColumnWidth)},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: _R.checkboxSize,
                  height: _R.checkboxSize,
                  child: Checkbox(
                    value: assignment.isCompleted,
                    onChanged: (value) =>
                        _assignmentCompletionChanged(assignmentIndex, value),
                  ),
                ),
              ),
              assignment.subject == null
                  ? Text(
                      assignment.name,
                      overflow: TextOverflow.ellipsis,
                      style: _R.getAssignmentNameTextStyle(context),
                    )
                  : Row(children: [
                      SubjectBlock(
                        name: assignment.subject.name,
                        color: assignment.subject.color,
                      ),
                      SizedBox(width: _R.assignmentSubjectNameSpacing),
                      Expanded(
                        child: Text(
                          assignment.name,
                          overflow: TextOverflow.ellipsis,
                          style: _R.getAssignmentNameTextStyle(context),
                        ),
                      ),
                    ]),
            ]),
            TableRow(children: [
              Container(),
              Text(
                _R.relativeDueDateString(
                    widget.now, assignment.dueDate, assignment.withDueTime),
                style: _R.dueTextStyle(context, dueColor),
              ),
            ]),
          ],
        ),
      ),
      onTap: () => _assignmentPressed(assignment),
    );
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation.drive(CurveTween(curve: _R.sizeTransitionCurve)),
      child: FadeTransition(
        opacity: animation.drive(Tween(begin: 0, end: 1)),
        child: assignmentWidget,
      ),
    );
  }

  List<Assignment> _getShownAssignments() {
    if (Settings().assignments == null) return [];
    // Unless the assignment is completed,
    // Show all assignments which are expired, due today and due tomorrow.
    // Show two future assignments if exist.
    // If no expired or future assignments, show all assignments with no due date.
    final sortedAssignments =
        Settings().assignments.where((a) => !a.isCompleted).toList()
          ..sort((a1, a2) {
            if (a1.dueDate == null && a2.dueDate == null) return 0;
            if (a1.dueDate == null) return -1;
            if (a2.dueDate == null) return 1;
            return a1.dueDate.compareTo(a2.dueDate);
          });

    final shownAssignments = <Assignment>[];
    final nowDate =
        DateTime.utc(widget.now.year, widget.now.month, widget.now.day);
    int futureAssignmentsCount = 0;
    for (final assignment in sortedAssignments) {
      if (assignment.dueDate == null) continue;
      final dueDateOnly = DateTime.utc(assignment.dueDate.year,
          assignment.dueDate.month, assignment.dueDate.day);
      if (dueDateOnly.difference(nowDate).inDays <= 1) {
        shownAssignments.add(assignment);
      } else if (futureAssignmentsCount < 2) {
        shownAssignments.add(assignment);
        futureAssignmentsCount++;
      }
    }

    if (shownAssignments.length == 0) {
      shownAssignments.addAll(sortedAssignments);
    }
    return shownAssignments;
  }

  void _assignmentCompletionChanged(int assignmentIndex, bool isCompleted) {
    final assignment = _shownAssignments[assignmentIndex];
    assignment.isCompleted = isCompleted;

    /// Don't update shown list when building
    _isInternalUpdating = true;
    Settings().assignmentListener.notifyListeners();

    // Update Checkbox
    setState(() {});

    // Check whether same assignment has already been scheduled removal.
    final existingTimerIndex = _removeDelayInfo.indexWhere(
        (keyValue) => identical(keyValue.key, assignment)); // -1 if not exist
    if (existingTimerIndex != -1) {
      // Timer exists
      _removeDelayInfo[existingTimerIndex].value.item1.cancel(); // Stop timer
      _removeDelayInfo.removeAt(existingTimerIndex); // Remove timer
    }
    final removeTimer = Timer(_R.completionRemovalDelay, () {
      if (isCompleted == false) return;

      // Determine any and which assignment is needed to be inserted into the list
      assignmentIndex =
          _shownAssignments.indexWhere((a) => identical(a, assignment));
      _listKey.currentState.removeItem(
        assignmentIndex,
        (context, animation) => AbsorbPointer(
            child: _buildAssignment(
                context, assignmentIndex, assignment, animation)),
      );

      final oldShownAssignments = _shownAssignments.map((a) => a).toList();
      _shownAssignments = _removeDelayInfo
          .firstWhere((keyValue) => identical(keyValue.key, assignment))
          .value
          .item2; // Retrieve shown assignments from _removeDelayInfo

      final nowDate =
          DateTime.utc(widget.now.year, widget.now.month, widget.now.day);

      if (_shownAssignments.length == 0) {
        // All assignments are completed. Show the empty message.
        _listKey.currentState.insertItem(0);
      } else if (assignment.dueDate != null) {
        final assignmentDueDateOnly = DateTime.utc(assignment.dueDate.year,
            assignment.dueDate.month, assignment.dueDate.day);

        if (oldShownAssignments.length == 1) {
          // All assignments with due date are completed. Show all assignments with no due date.
          for (int i = 0; i < _shownAssignments.length; i++) {
            _listKey.currentState.insertItem(i);
          }
        } else if (assignmentDueDateOnly.difference(nowDate).inDays > 1) {
          // An assignment which is not due in one day is completed. Show one more assignment.
          if (_shownAssignments
                  .where((a) =>
                      a.dueDate != null &&
                      DateTime.utc(a.dueDate.year, a.dueDate.month,
                                  a.dueDate.day)
                              .difference(nowDate)
                              .inDays >
                          1)
                  .length ==
              2) {
            _listKey.currentState.insertItem(_shownAssignments.length - 1);
          }
        }
      }
      _removeDelayInfo
          .removeWhere((keyValue) => identical(assignment, keyValue.key));
    });
    _removeDelayInfo.add(MapEntry(
        assignment,
        Tuple2(removeTimer,
            _getShownAssignments()))); // See documentation of `_removeDelayTimer`
  }

  void _assignmentPressed(Assignment assignment) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AssignmentScreen(assignment: assignment),
    ));
  }

  void _addAssignmentPressed() {
    final assignment = Assignment(
      isCompleted: false,
      name: '',
      description: '',
      subject: null,
      dueDate: null,
      withDueTime: false,
      notes: '',
    );
    Settings().assignments.add(assignment);
    Settings().assignmentListener.notifyListeners();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AssignmentScreen(assignment: assignment),
    ));
  }

  void _viewAssignmentsPressed() {
    // TODO: Implement this
  }

  void _settingsPressed() {
    // TODO: Implement this
  }
}
