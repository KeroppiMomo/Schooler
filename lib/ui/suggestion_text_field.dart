import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/cycle_calendar.dart';
import 'package:schooler/ui/week_calendar.dart';
import 'package:table_calendar/table_calendar.dart';

final SuggestionTextFieldResources _R = R.suggestionTextField;

class SuggestionTextField extends StatefulWidget {
  final String curValue;

  /// The minimum number of items for the suggestions widget to become a `ListView`.
  /// If the number of items is below this value, the items are placed in a `Column`.
  final int minItemForListView;
  final double listViewHeight;
  final List<String> Function(String) suggestionCallback;

  /// An optional widget builder for a suggestion.
  /// The builder function should has three arguments:
  /// build context, suggestion, and on submit function.
  final Widget Function(BuildContext, String, void Function())
      suggestionBuilder;
  final void Function(String) onDone;

  SuggestionTextField({
    this.curValue,
    this.minItemForListView,
    this.listViewHeight,
    this.suggestionCallback,
    this.suggestionBuilder,
    this.onDone,
  });

  @override
  State<StatefulWidget> createState() => SuggestionTextFieldState();

  // Convenient Picker
  static void showSubjectPicker(BuildContext context,
      {IconData subjectIcon,
      int minItemForListView,
      double listViewHeight,
      void Function(Subject) onDone}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SuggestionTextField(
            minItemForListView: minItemForListView,
            listViewHeight: listViewHeight,
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
                leading: Icon(subjectIcon, color: subject.color),
                title: Text(subject.name),
                onTap: onSubmit,
              );
            },
            onDone: (name) {
              final subject = Settings().subjects.firstWhere(
                  (subject) => subject.name == name,
                  orElse: () => Subject(name));
              onDone?.call(subject);
            },
          ),
        ),
      ),
    );
  }

  static void showDatePicker(BuildContext context,
      {Subject subject, void Function(DateTime) onDone}) {
    final monday =
        DateTime.now().add(Duration(days: 8 - DateTime.now().weekday));

    final subjectSessionDate = () {
      if (subject == null) return null;

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
          for (final holiday in dayInfo.holidays ?? <Event>[]) {
            final day = TimetableOccasionDay(holiday.name);
            if (existingDays.contains(day)) return day;
          }
          for (final occasion in dayInfo.occasions ?? <Event>[]) {
            final day = TimetableOccasionDay(occasion.name);
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

        if (sessions.any((session) => session.name == subject.name)) {
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
          onSelected: (dateTime, _) async => onDone(dateTime),
        );
      } else if (Settings().calendarType == CalendarType.cycle) {
        return CycleCalendar(
          calendarController: calendarController,
          cycleConfig: Settings().cycleConfig,
          calendarInfo: Settings().cycleConfig.getCalendar(),
          onSelected: (dateTime, _) async => onDone(dateTime),
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
                  pressedOpacity: _R.dateCancelOpacity,
                  padding: _R.dateCancelPadding,
                  child: Text(
                    _R.dateCancelText,
                    style: _R.dateCancelTextStyle,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              calendarWidget,
              Divider(),
              ListTile(
                leading: Icon(_R.dateChoiceIcon),
                title: Text(_R.dateTodayText),
                subtitle: Text(_R.dateFormat.format(DateTime.now())),
                trailing: Icon(_R.dateChoiceTrailing),
                onTap: () => onDone(DateTime.now()),
              ),
              ListTile(
                leading: Icon(_R.dateChoiceIcon),
                title: Text(_R.dateTomorrowText),
                subtitle: Text(_R.dateFormat
                    .format(DateTime.now().add(Duration(days: 1)))),
                trailing: Icon(_R.dateChoiceTrailing),
                onTap: () => onDone(DateTime.now().add(Duration(days: 1))),
              ),
              ListTile(
                leading: Icon(_R.dateChoiceIcon),
                title: Text(_R.dateMondayText),
                subtitle: Text(_R.dateFormat.format(monday)),
                trailing: Icon(_R.dateChoiceTrailing),
                onTap: () => onDone(monday),
              ),
              ...subjectSessionDate == null
                  ? []
                  : [
                      ListTile(
                        leading: Icon(_R.dateChoiceIcon),
                        title: Text(_R.getDateSubjectSession(subject.name)),
                        subtitle:
                            Text(_R.dateFormat.format(subjectSessionDate)),
                        trailing: Icon(_R.dateChoiceTrailing),
                        onTap: () => onDone(subjectSessionDate),
                      )
                    ],
            ],
          ),
        ),
      ),
    );
  }
}

class SuggestionTextFieldState extends State<SuggestionTextField> {
  TextEditingController _textFieldController;

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController(text: widget.curValue);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = widget.suggestionCallback == null
        ? []
        : widget.suggestionCallback(_textFieldController.text);
    Widget Function(BuildContext, String, void Function()) suggestionBuilder =
        widget.suggestionBuilder ??
            (_, suggestion, onSubmit) => ListTile(
                  title: Text(suggestion),
                  onTap: onSubmit,
                );
    final suggestionsChildren = suggestions
        .map((suggestion) =>
            suggestionBuilder(context, suggestion, () => _submit(suggestion)))
        .toList();
    return Column(
      children: [
        Container(
          height: 44.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                pressedOpacity: 0.3,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Cancel',
                  style: const TextStyle(color: Colors.black54, fontSize: 16.0),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                pressedOpacity: 0.3,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Done',
                  style: const TextStyle(color: Colors.blue, fontSize: 16.0),
                ),
                onPressed: () => _submit(_textFieldController.text),
              ),
            ],
          ),
        ),
        widget.minItemForListView <= suggestions.length
            ? Container(
                height: widget.listViewHeight,
                child: ListView(children: suggestionsChildren),
              )
            : Column(children: suggestionsChildren),
        ...(suggestions.length == 0 ? [] : [Divider()]),
        TextField(
            controller: _textFieldController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 16.0),
            ),
            autofocus: true,
            onChanged: (newValue) => setState(() {}),
            onSubmitted: _submit),
      ],
    );
  }

  void _submit(String newValue) {
    Navigator.pop(context);
    widget.onDone?.call(newValue);
  }
}
