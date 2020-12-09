import 'package:flutter/material.dart';
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/assignment_screen.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:schooler/ui/list_screen.dart';

AssignmentListScreenResources _R = R.assignmentListScreen;

class AssignmentsListScreen extends StatefulWidget {
  final Function onSwitchView;

  AssignmentsListScreen({Key key, this.onSwitchView}) : super(key: key);
  @override
  AssignmentsListScreenState createState() => AssignmentsListScreenState();
}

@visibleForTesting
class AssignmentsListScreenState extends State<AssignmentsListScreen> {
  @override
  Widget build(BuildContext context) {
    return ListScreen<Assignment>(
      appBarTitle: _R.appBarTitle,
      appBarActions: widget.onSwitchView == null
          ? null
          : [
              IconButton(
                icon: Icon(_R.switchViewIcon),
                tooltip: _R.switchViewTooltip,
                onPressed: widget.onSwitchView,
              ),
            ],
      addFABTooltip: _R.addFABTooltip,
      addFABIcon: _R.addFABIcon,
      source: () => Settings().assignments,
      sortings: _R.assignmentSorts,
      defaultSorting: _R.defaultSorting,
      defaultSortDirection: _R.defaultSortDirection,
      noSortText: _R.noSortText,
      searchString: _getSearchString,
      listener: Settings().assignmentListener,
      separatorBuilder: (context, i) =>
          Divider(indent: _R.assignmentCheckboxColumnWidth),
      itemBuilder: (_, assignment) => _buildAssignment(assignment),
      addPressed: _addPressed,
      itemPressed: _assignmentPressed,
    );
  }

  String _getSearchString(Assignment assignment) {
    return (assignment.name ?? '') +
        '\n' +
        (assignment.description ?? '') +
        '\n' +
        (assignment.subject?.name ?? '') +
        '\n' +
        (assignment.dueDate == null
            ? ''
            : _R.searchDueDateFormat.format(assignment.dueDate));
  }

  Widget _buildAssignment(Assignment assignment) {
    return Padding(
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
              opacity:
                  assignment.isCompleted ? _R.assignmentCompletedOpacity : 1.0,
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
          ...assignment.dueDate == null &&
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
                          text: (assignment.withDueTime
                                  ? _R.assignmentDueTimeFormat
                                  : _R.assignmentDueDateFormat)
                              .format(assignment.dueDate),
                          children: [
                            TextSpan(
                              text: assignment.description ?? '',
                              style: _R.assignmentDescriptionTextStyle(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ],
        ],
      ),
    );
  }

  void _addPressed() {
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
    Settings().saveSettings();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AssignmentScreen(assignment: assignment),
    ));
  }

  void _assignmentCompletionChanged(Assignment assignment, bool value) {
    assignment.isCompleted = value;
    Settings().assignmentListener.notifyListeners();
    Settings().saveSettings();
  }

  void _assignmentPressed(Assignment assignment) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AssignmentScreen(assignment: assignment),
    ));
  }
}
