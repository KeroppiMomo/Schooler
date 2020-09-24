import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:schooler/ui/time_picker.dart';
import 'package:schooler/ui/suggestion_text_field.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';

TimetableEditorResources _R = R.timetableEditor;

class TimetableEditor extends StatefulWidget {
  final List<TimetableSession> sessions;
  final void Function(int) onDelete;
  final void Function() onAdd;
  final void Function(int, DateTime) onStartTimeChange;
  final void Function(int, DateTime) onEndTimeChange;
  final void Function(int, String) onNameChange;
  final void Function(TimetableDay) onCopyTimeSlots;

  /// If `onRemoveDay` is null, the 'Remove Day' button is not shown
  final void Function() onRemoveDay;

  TimetableEditor({
    this.sessions,
    this.onDelete,
    this.onAdd,
    this.onStartTimeChange,
    this.onEndTimeChange,
    this.onNameChange,
    this.onCopyTimeSlots,
    this.onRemoveDay,
  });

  @override
  State createState() => TimetableEditorState();
}

class TimetableEditorState extends State<TimetableEditor> {
  GlobalKey<AnimatedListState> _listKey;

  @override
  void initState() {
    super.initState();
    _listKey = GlobalKey();
  }

  List<TimetableDay> getCopyableDays() {
    return Settings()
        .timetable
        .days
        .where((day) => Settings().timetable.sessionsOfDay(day).length != 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final copyableDays = getCopyableDays();
    return AnimatedList(
      key: _listKey,
      padding: _R.listPadding,
      initialItemCount: (widget.sessions.length == 0
              ? copyableDays.length
              : widget.sessions.length) +
          1 +
          (widget.onRemoveDay == null ? 0 : 1),
      // If there is no session, show 'copy days time slot' option buttons
      // +1 is for the "add" button
      // If onRemoveDay is null, do not show the 'Remove Day' button
      itemBuilder: (context, i, animation) {
        final copyableDays = getCopyableDays();
        if (i == widget.sessions.length) {
          return FlatButton.icon(
            label: Text(_R.addSessionButtonText),
            icon: Icon(_R.addSessionButtonIcon),
            onPressed: _addSessionPressed,
          );
        } else if (i ==
            (widget.sessions.length == 0
                    ? copyableDays.length
                    : widget.sessions.length) +
                1) {
          // One less than the length of list
          return FlatButton.icon(
            label: Text(_R.removeTimetableText),
            icon: Icon(_R.removeTimetableIcon),
            onPressed: widget.onRemoveDay,
          );
        } else if (widget.sessions.length == 0) {
          return _buildCopyTimeSlotsButton(
            copyableDays[i - 1],
            animation: animation,
          ); // i-1 because i=0 is the 'Add Session' button
        } else {
          return _buildTimetableSession(i, widget.sessions[i],
              animation: animation);
        }
      },
    );
  }

  Widget _buildCopyTimeSlotsButton(TimetableDay day, {Animation animation}) {
    final button = FlatButton.icon(
      label: Flexible(
        fit: FlexFit.loose,
        child: Text(
          _R.getCopyTimeSlotsText(_R.dayTabName(day)),
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
      ),
      icon: Icon(_R.copyTimeSlotsIcon),
      onPressed: () => _copyTimeSlots(day),
    );
    if (animation == null)
      return button;
    else
      return SizeTransition(
        axisAlignment: 1.0,
        sizeFactor:
            animation.drive(CurveTween(curve: _R.listItemsSizeTransitionCurve)),
        child: FadeTransition(
          opacity: animation.drive(Tween(begin: 0, end: 1)),
          child: SizedBox(
            width: double.infinity,
            child: button,
          ),
        ),
      );
  }

  /// Build a widget representing a TimetableSession.
  /// If `animation` is given, the returning widget is embed in SizeTransition and FadeTransition for use in AnimatedList.
  Widget _buildTimetableSession(int sessionIndex, TimetableSession session,
      {Animation animation}) {
    Widget _buildEditIcon() {
      return Icon(
        _R.sessionEditIcon,
        color: _R.sessionEditIconColor,
        size: _R.sessionEditIconSize,
      );
    }

    /// Builds a tapable region.
    Widget _buildEditRegion(List<Widget> children, {void Function() onTap}) {
      return InkWell(
        child: Padding(
          padding: _R.sessionEditRegionPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
        onTap: onTap,
      );
    }

    final subject = Settings().subjects.firstWhere(
          (subject) => subject.name == session.name,
          orElse: () => null,
        );

    final sessionWidget = Padding(
      padding: _R.sessionPadding,
      child: Row(
        children: [
          _buildEditRegion(
            [
              _buildEditIcon(),
              SizedBox(width: _R.sessionEditRegionWidgetsSpacing),
              Container(
                width: _R.sessionTimeWidth,
                child: Text(_R.sessionTimeFormat.format(session.startTime)),
              ),
            ],
            onTap: () => DatePicker.showPicker(
              context,
              showTitleActions: true,
              pickerModel: TimePicker.fiveMin(currentTime: session.startTime),
              onConfirm: (DateTime time) =>
                  _sessionStartOnChange(sessionIndex, time),
            ),
          ),
          Text(_R.sessionTimeTo),
          _buildEditRegion(
            [
              Container(
                width: _R.sessionTimeWidth,
                child: Text(_R.sessionTimeFormat.format(session.endTime)),
              ),
              SizedBox(width: _R.sessionEditRegionWidgetsSpacing),
              _buildEditIcon(),
            ],
            onTap: () => DatePicker.showPicker(
              context,
              showTitleActions: true,
              pickerModel: TimePicker.fiveMin(currentTime: session.endTime),
              onConfirm: (DateTime time) =>
                  _sessionEndOnChange(sessionIndex, time),
            ),
          ),
          Expanded(
            child: _buildEditRegion(
              [
                Expanded(
                  child: (session.name == null || session.name == '')
                      ? Text(
                          _R.sessionNoNameText,
                          style: R.placeholderTextStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      : (subject == null
                          ? Text(
                              session.name,
                              style: R.sessionTextStyle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          : SubjectBlock(
                              name: subject.name,
                              color: subject.color,
                            )),
                ),
                SizedBox(width: _R.sessionEditRegionWidgetsSpacing),
                _buildEditIcon(),
              ],
              onTap: () => _editSessionName(sessionIndex, session),
            ),
          ),
          _buildEditRegion(
            [
              Icon(
                _R.sessionDeleteIcon,
                size: _R.sessionDeleteIconSize,
                color: _R.sessionDeleteIconColor,
              )
            ],
            onTap: () => _deleteSessionPressed(sessionIndex, session),
          ),
        ],
      ),
    );

    if (animation == null)
      return sessionWidget;
    else
      return SizeTransition(
        axisAlignment: -1.0,
        sizeFactor:
            animation.drive(CurveTween(curve: _R.listItemsSizeTransitionCurve)),
        child: FadeTransition(
          opacity: animation.drive(Tween(begin: 0, end: 1)),
          child: sessionWidget,
        ),
      );
  }

  void _deleteSessionPressed(int sessionIndex, TimetableSession session) {
    _listKey.currentState.removeItem(
      sessionIndex,
      (context, animation) => AbsorbPointer(
        child:
            _buildTimetableSession(sessionIndex, session, animation: animation),
      ),
    );
    if (widget.onDelete != null) widget.onDelete(sessionIndex);
    if (widget.sessions.length == 0) {
      final copyableDays = getCopyableDays();
      for (int i = 0; i < copyableDays.length; i++) {
        _listKey.currentState.insertItem(i + 1);
      }
    }
  }

  void _editSessionName(int sessionIndex, TimetableSession session) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SuggestionTextField(
                minItemForListView: _R.suggestionMinItemForListView,
                listViewHeight: _R.suggestionListViewHeight,
                curValue: session.name,
                suggestionCallback: (pattern) {
                  Set<String> suggestionList = Set();
                  bool isMatch(String candidate) =>
                      (candidate != '') &&
                      (candidate.length >= pattern.length) &&
                      (candidate.substring(0, pattern.length).toLowerCase() ==
                          pattern.toLowerCase());

                  for (final sessions
                      in Settings().timetable?.timetable?.values ??
                          <List<TimetableSession>>[]) {
                    for (final session in sessions) {
                      if (isMatch(session.name)) {
                        suggestionList.add(session.name);
                      }
                    }
                  }

                  for (final subject in Settings().subjects ?? <Subject>[]) {
                    if (isMatch(subject.name)) {
                      suggestionList.add(subject.name);
                    }
                  }

                  return suggestionList.toList();
                },
                suggestionBuilder: (context, suggestion, onSubmit) {
                  final subject = Settings().subjects.firstWhere(
                      (subject) => subject.name == suggestion,
                      orElse: () => null);
                  return ListTile(
                    title: subject == null
                        ? Text(suggestion)
                        : SubjectBlock(
                            name: subject.name,
                            color: subject.color,
                          ),
                    onTap: onSubmit,
                  );
                },
                onDone: (newName) {
                  setState(() {
                    if (widget.onStartTimeChange != null)
                      widget.onNameChange(sessionIndex, newName);
                  });
                },
              ),
            ),
          );
        });
  }

  void _addSessionPressed() {
    if (widget.sessions.length == 0) {
      final copyableDays = getCopyableDays();
      for (int i = copyableDays.length - 1; i >= 0; i--) {
        _listKey.currentState.removeItem(
          i + 1,
          (context, animation) => AbsorbPointer(
            child: _buildCopyTimeSlotsButton(
              copyableDays[i],
              animation: animation,
            ),
          ),
        );
      }
    }

    widget.onAdd == null ? TimetableSession() : widget.onAdd();
    _listKey.currentState.insertItem(widget.sessions.length - 1);
  }

  void _sessionStartOnChange(int sessionIndex, DateTime newTime) {
    setState(() {
      if (widget.onStartTimeChange != null)
        widget.onStartTimeChange(sessionIndex, newTime);
    });
  }

  void _sessionEndOnChange(int sessionIndex, DateTime newTime) {
    setState(() {
      if (widget.onStartTimeChange != null)
        widget.onEndTimeChange(sessionIndex, newTime);
    });
  }

  void _copyTimeSlots(TimetableDay day) {
    final copyableDays = getCopyableDays();
    for (int i = copyableDays.length - 1; i >= 0; i--) {
      _listKey.currentState.removeItem(
        i + 1,
        (context, animation) => AbsorbPointer(
          child: _buildCopyTimeSlotsButton(
            copyableDays[i],
            animation: animation,
          ),
        ),
      );
    }

    widget.onCopyTimeSlots(day);

    for (int i = 0; i < widget.sessions.length; i++) {
      _listKey.currentState.insertItem(i);
    }
  }
}
