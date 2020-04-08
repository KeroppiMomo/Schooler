import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/setup/timetable_editor_screen.dart';
import 'package:schooler/ui/subject_block.dart';

TimetableScreenResources _R = R.timetableScreen;

class TimetableScreen extends StatefulWidget {
  final TimetableDay day;
  TimetableScreen({Key key, this.day}) : super(key: key);

  @override
  TimetableScreenState createState() => TimetableScreenState();
}

@visibleForTesting
class TimetableScreenState extends State<TimetableScreen> {
  @override
  Widget build(BuildContext context) {
    final initialTab =
        widget.day == null ? 0 : Settings().timetable.days.indexOf(widget.day);

    return ValueListenableBuilder(
      valueListenable: Settings().timetableListener,
      builder: (context, _, __) => DefaultTabController(
        initialIndex: initialTab == -1 ? 0 : initialTab,
        length: Settings().timetable.noOfDays,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_R.appBarTitle),
            actions: [
              IconButton(
                icon: Icon(_R.editIcon),
                tooltip: _R.editTooltip,
                onPressed: _editPressed,
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: Settings().timetable.days.map((TimetableDay day) {
                String name = '';
                if (day is TimetableWeekDay) {
                  name = _R.weekDayTabName(day.dayOfWeek);
                } else if (day is TimetableCycleDay) {
                  name = _R.cycleDayTabName(day.dayOfCycle);
                } else if (day is TimetableOccasionDay) {
                  name = day.occasionName;
                } else {
                  assert(false, 'Unexpected Timetableday subtype');
                }

                return Tab(text: name);
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: Settings()
                .timetable
                .timetable
                .keys
                .map(_buildTimetable)
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTimetable(TimetableDay day) {
    return ListView.builder(
      padding: _R.listPadding,
      itemCount: Settings().timetable.sessionsOfDay(day).length,
      itemBuilder: (context, i) =>
          _buildSession(Settings().timetable.sessionsOfDay(day)[i]),
    );
  }

  Widget _buildSession(TimetableSession session) {
    // null if it is not a subejct.
    final subject = Settings().subjects.firstWhere(
        (subject) => subject.name == session.name,
        orElse: () => null);
    return Padding(
      padding: _R.sessionPadding,
      child: Row(
        children: [
          SizedBox(
            width: _R.sessionTimeWidth,
            child: Text(
              _R.sessionTimeFormat.format(session.startTime),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: _R.sessionTimeStampSpacing),
          Text(_R.sessionTimeTo),
          SizedBox(width: _R.sessionTimeStampSpacing),
          SizedBox(
            width: _R.sessionTimeWidth,
            child: Text(
              _R.sessionTimeFormat.format(session.endTime),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(width: _R.sessionTimeNameSpacing),
          Expanded(
            child: subject != null
                ? SubjectBlock(name: subject.name, color: subject.color)
                : ((session.name == null || session.name == '')
                    ? Text(
                        _R.sessionNoNameText,
                        style: R.placeholderTextStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )
                    : Text(
                        session.name,
                        style: R.sessionTextStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )),
          ),
        ],
      ),
    );
  }

  void _editPressed() {
    Timetable currentTimetable =
        Timetable.fromJSON(Settings().timetable.toJSON());
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TimetableEditorScreen(
        isSetup: false,
        onPop: () {
          Settings().timetable = currentTimetable;
        },
        onDone: () {
          Settings().timetableListener.notifyListeners();
        },
      ),
    ));
  }
}
