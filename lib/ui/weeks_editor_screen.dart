import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/edit_text_screen.dart';
import 'package:schooler/ui/timetable_editor_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/lib/settings.dart';

/// Local resources.
final CalendarEditorResources _R = R.calendarEditor;

/// Screen for editing week configuration.
class WeeksEditorScreen extends StatefulWidget {
  void Function() onPop;

  WeeksEditorScreen({this.onPop});

  @override
  WeeksEditorScreenState createState() => WeeksEditorScreenState();
}

@visibleForTesting
class WeeksEditorScreenState extends State<WeeksEditorScreen> {
  /// Calendar controller for all `TableCalendar` instances.
  CalendarController _calendarController;

  /// Scroll offset for the `ListView` in the selection view.
  double _selectionScrollOffset = 0;

  /// True if the `ExpansionTile` for holidays in the option view is expanded. Used for rebuilding the widget.
  bool _isHolidaysExpanded = true;

  /// The list of holiday `Event.id`s corresponding to the expanded `ExpansionTile`. Used for rebuilding the widget.
  List<String> _holidayIDsExpanded = [];

  /// True if the `ExpansionTile` for occasions in the option view is expanded. Used for rebuilding the widget.
  bool _isOccasionsExpanded = true;

  /// The list of occasion `Event.id`s corresponding to the expanded `ExpansionTile`. Used for rebuilding the widget.
  List<String> _occasionIDsExpanded = [];

  /// Current week config.
  WeekConfig _weekConfig;

  /// Calendar info for the current week config `_weekConfig`.
  Map<DateTime, CalendarDayInfo> _curCalendarInfo;

  /// This screen has two "views": option view and selection view.
  /// The option view shows all available settings for the week config,
  /// while the selection view prompts the user to select a date from the calendar for a setting.
  ///
  /// The option view and the selection view can be made by calling `_buildOptionView` and `_buildSelectionView` respectively.
  Widget _currentView;

  @override
  void initState() {
    super.initState();

    if (Settings().timetable != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _donePressed();
      });
    }

    _calendarController = CalendarController();
    if (Settings().weekConfig == null) {
      _weekConfig = _R.defaultWeekConfig;
      Settings().weekConfig = _weekConfig;
      Settings().saveSettings();
    } else {
      _weekConfig = Settings().weekConfig;
    }
    _curCalendarInfo = _weekConfig.getCalendar();
  }

  @override
  void dispose() {
    _calendarController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == null) _currentView = _buildOptionView();

    // `AnimatedSwitcher` provides a fade transition when the `child` property is changed.
    return AnimatedSwitcher(
      duration: _R.fadeDuration,
      child: _currentView,
    );
  }

  /// Create the main calendar.
  ///
  /// `onSelected` is called when a date is selected from the calendar.
  Widget _buildCalendar({void Function(DateTime selected) onSelected}) {
    Widget dayBuilder(
        BuildContext context, DateTime dateTime, bool isOutsideMonth) {
      /// Change the `textStyle` color to gray if the current `dateTime` `isOutsideMonth` or not between startSchoolYear and endSchoolYear.
      /// Used for the `textStyle` of the day `Text` (the largest text for displaying the day of the month).
      TextStyle changeColorIfOutside(TextStyle textStyle) {
        return isOutsideMonth ||
                dateTime.isBefore(_weekConfig.startSchoolYear) ||
                dateTime.isAfter(_weekConfig.endSchoolYear
                    .add(Duration(days: 1))) // No idea why need to add 1 day
            ? textStyle.copyWith(color: _R.outsideMonthColor)
            : textStyle;
      }

      final calendarInfo =
          _curCalendarInfo[removeTimeFrom(dateTime)] ?? CalendarDayInfo();
      final contentWidget = () {
        if (calendarInfo.holidays != null) {
          if ((calendarInfo.holidays ?? '') != '') {
            return Column(
              children: <Widget>[
                Spacer(),
                Text(
                  dateTime.day.toString(),
                  style: _R.getCalendarDayTextTheme(context).copyWith(
                        color: _R.calendarHolidayColor,
                        decoration: calendarInfo.occasions == null
                            ? null
                            : TextDecoration.underline,
                      ),
                ),
                Text(
                  calendarInfo.holidays,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: _R
                      .getCalendarDayInfoTextTheme(context)
                      .copyWith(color: _R.calendarHolidayColor),
                ),
                Spacer(),
              ],
            );
          } else {
            return Column(
              children: <Widget>[
                Spacer(),
                Text(
                  dateTime.day.toString(),
                  style: _R.getCalendarDayTextTheme(context).copyWith(
                        color: _R.calendarHolidayColor,
                        decoration: calendarInfo.occasions == null
                            ? null
                            : TextDecoration.underline,
                      ),
                ),
                Text(
                  (calendarInfo.occasions ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: changeColorIfOutside(
                      _R.getCalendarDayInfoTextTheme(context)),
                ),
                Spacer(),
              ],
            );
          }
        } else if (calendarInfo.occasions != null) {
          return Column(
            children: <Widget>[
              Spacer(),
              Text(
                dateTime.day.toString(),
                style: changeColorIfOutside(_R.getCalendarDayTextTheme(context))
                    .copyWith(decoration: TextDecoration.underline),
              ),
              Text(
                (calendarInfo.occasions ?? '').toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: changeColorIfOutside(
                    _R.getCalendarDayInfoTextTheme(context)),
              ),
              Spacer(),
            ],
          );
        } else {
          return Column(
            children: <Widget>[
              Spacer(),
              Text(
                dateTime.day.toString(),
                style: changeColorIfOutside(Theme.of(context).textTheme.body1),
              ),
              Text(''),
              Spacer(),
            ],
          );
        }
      }();

      if (calendarInfo.isStartSchoolYear || calendarInfo.isEndSchoolYear) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: calendarInfo.isStartSchoolYear
                    ? _R.calendarStartColor
                    : _R.calendarEndColor,
                shape: BoxShape.circle,
              ),
            ),
            contentWidget,
          ],
        );
      } else {
        return contentWidget;
      }
    }

    return TableCalendar(
      initialSelectedDay: _calendarController.focusedDay,
      initialCalendarFormat: CalendarFormat.month,
      availableCalendarFormats: {
        // There is a bug in the package
        CalendarFormat.month: 'Week',
        CalendarFormat.twoWeeks: 'Month',
        CalendarFormat.week: '2 Weeks',
      },
      calendarController: _calendarController,
      builders: CalendarBuilders(
        dayBuilder: (BuildContext context, DateTime dateTime, List events) =>
            dayBuilder(context, dateTime, false),
        outsideDayBuilder:
            (BuildContext context, DateTime dateTime, List events) =>
                dayBuilder(context, dateTime, true),
        outsideWeekendDayBuilder:
            (BuildContext context, DateTime dateTime, List events) =>
                dayBuilder(context, dateTime, true),
      ),
      onDaySelected: (dateTime, events) {
        if (onSelected != null) onSelected(dateTime);
      },
    );
  }

  /// Create a widget for the option view. See documentation for `_currentView`.
  Widget _buildOptionView() {
    return WillPopScope(
      onWillPop: () async {
        widget.onPop?.call();
        return true;
      },
      child: Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
          title: Text(_R.weeksAppBarTitle),
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildCalendar(),
              Divider(),
              Expanded(child: _buildOptions()),
              Divider(),
              FlatButton(
                child: Text(_R.doneButtonText),
                onPressed: _donePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Create the option section of the option view.
  Widget _buildOptions() {
    /// Build an option with a type of `DateTime`.
    ///
    /// When a date is selected from the calendar, `onSelected` will be called.
    /// If `onSelected` returns true, the selection view will be dismissed and return to the option view.
    Widget buildDateOption({
      @required String name,
      @required DateTime dateTime,
      @required bool Function(DateTime) onSelected,
    }) {
      return ListTile(
        leading: Icon(_R.dateOptionIcon),
        title: Text(name),
        subtitle: Text(_R.dateOptionDateFormat.format(dateTime)),
        trailing: Icon(_R.dateOptionEditIcon),
        onTap: () {
          setState(() {
            _currentView = _buildSelectionView(name, dateTime, onSelected);
          });
        },
      );
    }

    /// Build an option with a type of `bool`.
    Widget buildCheckboxOption({
      @required String name,
      @required bool value,
      @required void Function(bool) onChanged,
    }) {
      return CheckboxListTile(
        secondary: Icon(Icons.list),
        title: Text(name),
        value: value,
        onChanged: (bool newValue) {
          setState(() {
            onChanged(newValue);
            _curCalendarInfo = _weekConfig.getCalendar();
            _currentView = _buildOptionView();
          });
        },
      );
    }

    /// Build an option with a type of `String`.
    Widget buildTextOption({
      @required String name,
      @required String value,
      @required void Function(String) onChanged,
    }) {
      return ListTile(
        leading: Icon(_R.textOptionIcon),
        title: Text(name),
        subtitle: Text(value),
        trailing: Icon(_R.textOptionEditIcon),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditTextScreen(
              title: name,
              value: value,
              onDone: (changed) {
                setState(() {
                  onChanged(changed);

                  _curCalendarInfo = _weekConfig.getCalendar();
                  _currentView = _buildOptionView();
                });
              },
            ),
          ));
        },
      );
    }

    /// Build the events options, i.e. holidays and occasions.
    ///
    /// `addNewText` and `onAddNewPressed` refer to the "Add Event" button.
    /// `isTitleExpanded` and `onTitleExpansionChanged` refer to the `ExpansionTile` showing the `name`.
    Widget buildEventsOption({
      @required String name,
      @required List<Event> events,
      @required String addNewText,
      @required void Function(DateTime eventDate) onAddNewPressed,
      @required void Function(Event event) onEventDeleted,
      @required bool isTitleExpanded,
      @required void Function(bool isExpanded) onTitleExpansionChanged,
      @required List<String> expandedEventIDs,
      @required
          void Function(String eventID, bool isExpanded)
              onEventIDExpansionChanged,
    }) {
      return ExpansionTile(
        leading: Icon(_R.eventTitleIcon),
        title: Text(name),
        initiallyExpanded: isTitleExpanded,
        onExpansionChanged: onTitleExpansionChanged,
        children: <Widget>[
          ...events.map(
            (event) => ExpansionTile(
              title: Text(event.startDate == event.endDate
                  ? '${event.name} (${_R.eventTitleDateFormat.format(event.startDate)})'
                  : '${event.name} (${_R.eventTitleDateFormat.format(event.startDate)} – ${_R.eventTitleDateFormat.format(event.endDate)})'),
              leading: Icon(_R.eventIcon),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(_R.eventEditIcon),
                  IconButton(
                    icon: Icon(_R.eventDeleteIcon),
                    onPressed: () {
                      setState(() {
                        onEventDeleted(event);
                        _curCalendarInfo = _weekConfig.getCalendar();
                        _currentView = _buildOptionView();
                      });
                    },
                  ),
                ],
              ),
              initiallyExpanded: expandedEventIDs.contains(event.id),
              onExpansionChanged: (isExpanded) =>
                  onEventIDExpansionChanged(event.id, isExpanded),
              children: <Widget>[
                buildTextOption(
                  name: _R.eventNameText,
                  value: event.name,
                  onChanged: (changed) {
                    event.name = changed;
                  },
                ),
                buildDateOption(
                  name: _R.eventStartText,
                  dateTime: event.startDate,
                  onSelected: (selected) {
                    if (!selected.isBefore(_weekConfig.startSchoolYear) &&
                        !selected.isAfter(event.endDate)) {
                      event.startDate = selected;
                      return true;
                    } else {
                      return false;
                    }
                  },
                ),
                buildDateOption(
                  name: _R.eventEndText,
                  dateTime: event.endDate,
                  onSelected: (selected) {
                    if (!selected.isAfter(_weekConfig.endSchoolYear) &&
                        !selected.isBefore(event.startDate)) {
                      event.endDate = selected;
                      return true;
                    } else {
                      return false;
                    }
                  },
                ),
              ],
            ),
          ),
          FlatButton.icon(
            icon: Icon(_R.addEventIcon),
            label: Text(addNewText),
            onPressed: () {
              setState(() {
                final eventDate = removeTimeFrom(() {
                  // Want to set it to `_calendarController.focusedDay`
                  // If it is before start of school year, set it to start of school year
                  // If it is after end of school year, set it to end of school year
                  if (_calendarController.focusedDay
                      .isBefore(_weekConfig.startSchoolYear))
                    return _weekConfig.startSchoolYear;
                  if (_calendarController.focusedDay
                      .isAfter(_weekConfig.endSchoolYear))
                    return _weekConfig.endSchoolYear;

                  return _calendarController.focusedDay;
                }());
                _calendarController.setFocusedDay(eventDate);
                onAddNewPressed(eventDate);
                _curCalendarInfo = _weekConfig.getCalendar();
                _currentView = _buildOptionView();
              });
            },
          ),
        ],
      );
    }

    final scrollController =
        ScrollController(initialScrollOffset: _selectionScrollOffset);
    scrollController
        .addListener(() => _selectionScrollOffset = scrollController.offset);

    return ListView(controller: scrollController, children: <Widget>[
      buildDateOption(
        name: _R.startSchoolYearOptionText,
        dateTime: _weekConfig.startSchoolYear,
        onSelected: (selected) {
          if (selected.isBefore(_weekConfig.endSchoolYear)) {
            _weekConfig.startSchoolYear = selected;
            Settings().weekConfig = _weekConfig;
            Settings().saveSettings();
            return true;
          } else {
            return false;
          }
        },
      ),
      buildDateOption(
        name: _R.endSchoolYearOptionText,
        dateTime: _weekConfig.endSchoolYear,
        onSelected: (selected) {
          if (selected.isAfter(_weekConfig.startSchoolYear)) {
            _weekConfig.endSchoolYear = selected;
            Settings().weekConfig = _weekConfig;
            Settings().saveSettings();
            return true;
          } else {
            return false;
          }
        },
      ),
      buildCheckboxOption(
        name: _R.saturdayHolidayOptionText,
        value: _weekConfig.isSaturdayHoliday,
        onChanged: (value) {
          _weekConfig.isSaturdayHoliday = value;
          Settings().weekConfig = _weekConfig;
          Settings().saveSettings();
        },
      ),
      buildCheckboxOption(
        name: _R.sundayHolidayOptionText,
        value: _weekConfig.isSundayHoliday,
        onChanged: (value) {
          _weekConfig.isSundayHoliday = value;
          Settings().weekConfig = _weekConfig;
          Settings().saveSettings();
        },
      ),
      buildEventsOption(
        name: _R.holidaysOptionText,
        events: _weekConfig.holidays,
        addNewText: _R.addHolidayText,
        onAddNewPressed: (eventDate) {
          _weekConfig.holidays.add(Event(
            id: Event.generateID(),
            name: _R.newHolidayName,
            skipDay: _R.newHolidaySkipDay,
            startDate: eventDate,
            endDate: eventDate,
          ));
        },
        onEventDeleted: (event) {
          _holidayIDsExpanded.remove(event.id);
          _weekConfig.holidays.remove(event);
        },
        isTitleExpanded: _isHolidaysExpanded,
        onTitleExpansionChanged: (isExpanded) {
          _isHolidaysExpanded = isExpanded;
          _holidayIDsExpanded.clear();
        },
        expandedEventIDs: _holidayIDsExpanded,
        onEventIDExpansionChanged: (eventID, isExpanded) {
          (isExpanded
              ? _holidayIDsExpanded.add
              : _holidayIDsExpanded.remove)(eventID);
        },
      ),
      buildEventsOption(
        name: _R.occasionsOptionText,
        events: _weekConfig.occasions,
        addNewText: _R.addOccasionText,
        onAddNewPressed: (eventDate) {
          _weekConfig.occasions.add(Event(
            id: Event.generateID(),
            name: _R.newOccasionName,
            skipDay: _R.newOccasionSkipDay,
            startDate: eventDate,
            endDate: eventDate,
          ));
        },
        onEventDeleted: (event) {
          _occasionIDsExpanded.remove(event.id);
          _weekConfig.occasions.remove(event);
        },
        isTitleExpanded: _isOccasionsExpanded,
        onTitleExpansionChanged: (isExpanded) {
          _isOccasionsExpanded = isExpanded;
          _occasionIDsExpanded.clear();
        },
        expandedEventIDs: _occasionIDsExpanded,
        onEventIDExpansionChanged: (eventID, isExpanded) {
          (isExpanded
              ? _occasionIDsExpanded.add
              : _occasionIDsExpanded.remove)(eventID);
        },
      ),
    ]);
  }

  /// Create a widget for the selection view. See documentation for `_currentView`.
  ///
  /// When a date is selected from the calendar, `onSelected` will be called.
  /// If `onSelected` returns true, the selection view will be dismissed and return to the option view.
  Widget _buildSelectionView(String fieldName, DateTime currentSelection,
      bool Function(DateTime selected) onSelected) {
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(
        title: Text(_R.weeksAppBarTitle),
        leading: IconButton(
          icon: Icon(_R.selectionCloseIcon),
          onPressed: _closeSelection,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildCalendar(onSelected: (selected) {
              if (onSelected(removeTimeFrom(selected))) {
                setState(() {
                  _curCalendarInfo = _weekConfig.getCalendar();
                  _currentView = _buildOptionView();
                });
              }
            }),
            Divider(),
            Expanded(
              child: Padding(
                padding: _R.selectionMessagePadding,
                child: Text(
                  _R.getSelectionMessage(fieldName),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Divider(),
            FlatButton(
              child: Text(_R.selectionCancelText),
              onPressed: _closeSelection,
            ),
          ],
        ),
      ),
    );
  }

  /// Close the selection view and return to the option view.
  void _closeSelection() {
    setState(() {
      _currentView = _buildOptionView();
    });
  }

  /// When "Done" button is pressed, navigate to `timetableEditorScreen`.
  void _donePressed() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TimetableEditorScreen(onPop: () {
              Settings().timetable = null;
              Settings().saveSettings();
            })));
  }
}
