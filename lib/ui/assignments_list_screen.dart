import 'package:flutter/material.dart';
import 'package:schooler/lib/assignment.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/assignment_screen.dart';
import 'package:schooler/ui/subject_block.dart';

AssignmentListScreenResources _R = R.assignmentListScreen;

class AssignmentsListScreen extends StatefulWidget {
  final Function onSwitchView;

  AssignmentsListScreen({Key key, this.onSwitchView}) : super(key: key);
  @override
  AssignmentsListScreenState createState() => AssignmentsListScreenState();
}

enum SortDirection { ascending, descending }

@visibleForTesting
class AssignmentsListScreenState extends State<AssignmentsListScreen> {
  MapEntry<String, Comparable Function(Assignment)> _sorting =
      _R.defaultSorting;
  SortDirection _sortDirection = _R.defaultSortDirection;

  TextEditingController _searchBarController;

  /// Total number of assignments in Settings last time refreshed.
  /// This variable is to determine whether an assignment is added
  /// or removed.
  int _totalNoOfAssignments = 0;

  @override
  void initState() {
    super.initState();
    _searchBarController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _totalNoOfAssignments = Settings().assignments.length;
    List<Assignment> assignments = _sortAssignments(
        _filterSearchAssignments(Settings().assignments ?? []));
    return Scaffold(
      appBar: AppBar(
        title: Text(_R.appBarTitle),
        actions: widget.onSwitchView == null
            ? null
            : [
                IconButton(
                  icon: Icon(_R.switchViewIcon),
                  tooltip: _R.switchViewTooltip,
                  onPressed: widget.onSwitchView,
                ),
              ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        tooltip: _R.addFABTooltip,
        child: Icon(_R.addFABIcon),
        onPressed: () => _addAssignmentPressed(),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchBarController,
            decoration: InputDecoration(
              filled: true,
              prefixIcon: Icon(_R.searchBarIcon),
              suffixIcon: IconButton(
                icon: Icon(_R.searchBarClearIcon),
                tooltip: _R.searchBarClearTooltip,
                onPressed: _searchBarCleared,
              ),
              hintText: _R.searchBarHintText,
            ),
            onChanged: _searchBarChanged,
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Settings().assignmentListener,
              builder: (context, _, __) {
                if (Settings().assignments.length != _totalNoOfAssignments) {
                  assignments = _sortAssignments(
                      _filterSearchAssignments(Settings().assignments ?? []));
                  _totalNoOfAssignments = Settings().assignments.length;
                }

                return RefreshIndicator(
                  child: ListView.separated(
                    padding: _R.listViewPadding,
                    itemCount: assignments.length + 1, // +1 is the sort row
                    separatorBuilder: (context, i) =>
                        Divider(indent: _R.assignmentCheckboxColumnWidth),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Row(children: <Widget>[
                          Text(_R.sortText),
                          SizedBox(width: _R.sortTextChipsSpacing),
                          Expanded(
                            child: SizedBox(
                              height: _R.sortRowHeight,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (var entry in _R.assignmentSorts.entries)
                                    Row(children: [
                                      FilterChip(
                                        avatar: (_sorting != null &&
                                                entry.key == _sorting.key)
                                            ? Icon(
                                                _sortDirection ==
                                                        SortDirection.ascending
                                                    ? Icons.arrow_drop_up
                                                    : Icons.arrow_drop_down,
                                              )
                                            : null,
                                        label: Text(entry.key),
                                        showCheckmark: false,
                                        selectedColor: _R
                                            .getSortChipSelectedColor(context),
                                        selected: _sorting != null &&
                                            entry.key == _sorting.key,
                                        onSelected: (_) =>
                                            _sortingPressed(entry),
                                      ),
                                      SizedBox(width: _R.sortChipsSpacing),
                                    ]),
                                  FilterChip(
                                    // Just follow the order of assignment list (or reversed)
                                    avatar: _sorting == null
                                        ? Icon(
                                            _sortDirection ==
                                                    SortDirection.ascending
                                                ? _R.sortAscendingIcon
                                                : _R.sortDescendingIcon,
                                          )
                                        : null,
                                    label: Text(_R.noSortText),
                                    showCheckmark: false,
                                    selectedColor:
                                        _R.getSortChipSelectedColor(context),
                                    selected: _sorting == null,
                                    onSelected: (_) => _sortingPressed(null),
                                  ),
                                  SizedBox(width: _R.sortChipsSpacing),
                                ],
                              ),
                            ),
                          ),
                        ]);
                      }
                      return _buildAssignment(assignments[i - 1]);
                    },
                  ),
                  onRefresh: _onRefresh,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignment(Assignment assignment) {
    return InkWell(
      key: ValueKey(assignment),
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

  List<Assignment> _sortAssignments(List<Assignment> assignments) {
    if (_sorting == null) {
      if (_sortDirection == SortDirection.ascending)
        return assignments;
      else
        return assignments.reversed.toList();
    } else {
      final cloned = assignments.map((a) => a).toList();
      cloned.sort((a1, a2) {
        final sortValue1 = _sorting.value(a1);
        final sortValue2 = _sorting.value(a2);
        if (_sortDirection == SortDirection.ascending) {
          return Comparable.compare(sortValue1, sortValue2);
        } else {
          return Comparable.compare(sortValue2, sortValue1);
        }
      });
      return cloned;
    }
  }

  List<Assignment> _filterSearchAssignments(List<Assignment> assignments) {
    final patterns = _searchBarController.text.trim().toLowerCase().split(' ');
    return assignments.where((assignment) {
      final searchString = (assignment.name ?? '') +
          '\n' +
          (assignment.description ?? '') +
          '\n' +
          (assignment.subject?.name ?? '') +
          '\n' +
          (assignment.dueDate == null
              ? ''
              : _R.searchDueDateFormat.format(assignment.dueDate));
      return patterns
          .every((pattern) => searchString.toLowerCase().contains(pattern));
    }).toList();
  }

  void _searchBarCleared() {
    setState(() {
      _searchBarController.clear();
    });
  }

  void _searchBarChanged(String text) {
    setState(() {});
  }

  /// `sorting` can be null.
  void _sortingPressed(
      MapEntry<String, Comparable Function(Assignment)> sorting) {
    setState(() {
      if (this._sorting?.key == sorting?.key) {
        if (_sortDirection == SortDirection.ascending)
          _sortDirection = SortDirection.descending;
        else
          _sortDirection = SortDirection.ascending;
      } else {
        this._sorting = sorting;
        _sortDirection = SortDirection.ascending;
      }
    });
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

  Future<void> _onRefresh() async {
    setState(() {});
    await Future.delayed(_R.refreshDelay);
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
    Settings().saveSettings();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AssignmentScreen(assignment: assignment),
    ));
  }
}
