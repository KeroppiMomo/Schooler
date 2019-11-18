import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/edit_text_screen.dart';
import 'package:spinner_input/spinner_input.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:schooler/lib/cycle_config.dart';
import 'package:uuid/uuid.dart';

/// Local resources.
final CyclesEditorResources _R = R.cyclesEditor;

/// Screen for editing cycle configuration.
class CyclesEditorScreen extends StatefulWidget {
  @override
  CyclesEditorScreenState createState() => CyclesEditorScreenState();
}

@visibleForTesting
class CyclesEditorScreenState extends State<CyclesEditorScreen> {
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

  /// Current cycle config.
  CycleConfig _cycleConfig;

  /// Calendar info for the current cycle config `_cycleConfig`.
  Map<DateTime, Map<DayInfoType, Object>> _curCalendarInfo;

  /// This screen has two "views": option view and selection view.
  /// The option view shows all available settings for the cycle config,
  /// while the selection view prompts the user to select a date from the calendar for a setting.
  ///
  /// The option view and the selection view can be made by calling `_buildOptionView` and `_buildSelectionView` respectively.
  Widget _currentView;

  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController();
    // Default value for `_cycleConfig`
    _cycleConfig = CycleConfig(
      startSchoolYear: DateTime.utc(2019, 9, 2),
      endSchoolYear: DateTime.utc(2020, 7, 15),
      noOfDaysInCycle: 6,
      isSaturdayHoliday: true,
      isSundayHoliday: true,
      holidays: [],
      occasions: [],
    );
    _curCalendarInfo = _cycleConfig.getCalendar();
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
      duration: Duration(milliseconds: 250),
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
                dateTime.isBefore(_cycleConfig.startSchoolYear) ||
                dateTime.isAfter(_cycleConfig.endSchoolYear
                    .add(Duration(days: 1))) // No idea why need to add 1 day
            ? textStyle.copyWith(color: _R.outsideMonthColor)
            : textStyle;
      }

      final calendarInfo = _curCalendarInfo[removeTimeFrom(dateTime)] ?? {};
      final contentWidget = () {
        if (calendarInfo[DayInfoType.holiday] != null) {
          return Column(
            children: <Widget>[
              Spacer(),
              Text(
                dateTime.day.toString(),
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.red)
                    .copyWith(
                        decoration: calendarInfo[DayInfoType.occasions] == null
                            ? null
                            : TextDecoration.underline),
              ),
              Text(
                calendarInfo[DayInfoType.holiday].toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: Colors.red),
              ),
              Spacer(),
            ],
          );
        } else if (calendarInfo[DayInfoType.occasions] != null) {
          return Column(
            children: <Widget>[
              Spacer(),
              Text(
                dateTime.day.toString(),
                style: changeColorIfOutside(Theme.of(context).textTheme.body1)
                    .copyWith(decoration: TextDecoration.underline),
              ),
              Text(
                (calendarInfo[DayInfoType.occasions] ?? '').toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style:
                    changeColorIfOutside(Theme.of(context).textTheme.caption),
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
              Text(
                (calendarInfo[DayInfoType.cycleDay] ?? '').toString(),
                textAlign: TextAlign.center,
                style:
                    changeColorIfOutside(Theme.of(context).textTheme.caption),
              ),
              Spacer(),
            ],
          );
        }
      }();

      if (calendarInfo[DayInfoType.startSchoolYear] == true ||
          calendarInfo[DayInfoType.endSchoolYear] == true) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: calendarInfo[DayInfoType.startSchoolYear] == true
                    ? Color(0xFFB5F0A5)
                    : Color(0xFFF0A5A5),
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
      availableCalendarFormats: {
        CalendarFormat.month: 'Month'
      }, // The format option will be not shown
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
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(
        title: Text('Cycles Editor'),
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
              child: Text('Done'),
              onPressed: () {},
            ),
          ],
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
        leading: Icon(Icons.date_range),
        title: Text(name),
        subtitle: Text(_R.dateFormat.format(dateTime)),
        trailing: Icon(Icons.edit),
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
            _curCalendarInfo = _cycleConfig.getCalendar();
            _currentView = _buildOptionView();
          });
        },
      );
    }

    /// Build an option with a type of `int`.
    Widget buildSpinnerOption({
      @required String name,
      @required int value,
      @required void Function(int) onChanged,
    }) {
      return ListTile(
        leading: Icon(Icons.list),
        title: Text(name),
        trailing: SpinnerInput(
          disabledLongPress: true,
          spinnerValue: value.toDouble(),
          minValue: 1,

          minusButton: SpinnerButtonStyle(
            color: Theme.of(context).accentColor,
            textColor:
                Theme.of(context).accentColorBrightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
          ),
          plusButton: SpinnerButtonStyle(
            color: Theme.of(context).accentColor,
            textColor:
                Theme.of(context).accentColorBrightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
          ), // Different instance for `minusButton` and `plusButton` because `SpinnerButtonStyle.child` changes during the initialize of `SpinnerInput`

          onChange: (newValue) {
            setState(() {
              onChanged(newValue.toInt());
              _curCalendarInfo = _cycleConfig.getCalendar();
              _currentView = _buildOptionView();
            });
          },
        ),
      );
    }

    /// Build an option with a type of `String`.
    Widget buildTextOption({
      @required String name,
      @required String value,
      @required void Function(String) onChanged,
    }) {
      return ListTile(
        leading: Icon(Icons.text_fields),
        title: Text(name),
        subtitle: Text(value),
        trailing: Icon(Icons.edit),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditTextScreen(
              title: name,
              value: value,
              onDone: (changed) {
                setState(() {
                  onChanged(changed);

                  _curCalendarInfo = _cycleConfig.getCalendar();
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
        leading: Icon(Icons.date_range),
        title: Text(name),
        initiallyExpanded: isTitleExpanded,
        onExpansionChanged: onTitleExpansionChanged,
        children: <Widget>[
          ...events.map(
            (event) => ExpansionTile(
              title: Text(event.name),
              leading: Icon(Icons.event),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.edit),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        onEventDeleted(event);
                        _curCalendarInfo = _cycleConfig.getCalendar();
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
                  name: "Name",
                  value: event.name,
                  onChanged: (changed) {
                    event.name = changed;
                  },
                ),
                buildDateOption(
                  name: "From",
                  dateTime: event.startDate,
                  onSelected: (selected) {
                    if (!selected.isBefore(_cycleConfig.startSchoolYear) &&
                        !selected.isAfter(event.endDate)) {
                      event.startDate = selected;
                      return true;
                    } else {
                      return false;
                    }
                  },
                ),
                buildDateOption(
                  name: "To",
                  dateTime: event.endDate,
                  onSelected: (selected) {
                    if (!selected.isAfter(_cycleConfig.endSchoolYear) &&
                        !selected.isBefore(event.startDate)) {
                      event.endDate = selected;
                      return true;
                    } else {
                      return false;
                    }
                  },
                ),
                buildCheckboxOption(
                  name: "Skip Day",
                  value: event.skipDay,
                  onChanged: (changed) => event.skipDay = changed,
                ),
              ],
            ),
          ),
          FlatButton.icon(
            icon: Icon(Icons.add),
            label: Text(addNewText),
            onPressed: () {
              setState(() {
                final eventDate = removeTimeFrom(() {
                  // Want to set it to `_calendarController.focusedDay`
                  // If it is before start of school year, set it to start of school year
                  // If it is after end of school year, set it to end of school year
                  if (_calendarController.focusedDay
                      .isBefore(_cycleConfig.startSchoolYear))
                    return _cycleConfig.startSchoolYear;
                  if (_calendarController.focusedDay
                      .isAfter(_cycleConfig.endSchoolYear))
                    return _cycleConfig.endSchoolYear;

                  return _calendarController.focusedDay;
                }());
                _calendarController.setFocusedDay(eventDate);
                onAddNewPressed(eventDate);
                _curCalendarInfo = _cycleConfig.getCalendar();
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
        name: 'Start of School Year',
        dateTime: _cycleConfig.startSchoolYear,
        onSelected: (selected) {
          if (selected.isBefore(_cycleConfig.endSchoolYear)) {
            _cycleConfig.startSchoolYear = selected;
            return true;
          } else {
            return false;
          }
        },
      ),
      buildDateOption(
        name: 'End of School Year',
        dateTime: _cycleConfig.endSchoolYear,
        onSelected: (selected) {
          if (selected.isAfter(_cycleConfig.startSchoolYear)) {
            _cycleConfig.endSchoolYear = selected;
            return true;
          } else {
            return false;
          }
        },
      ),
      buildCheckboxOption(
        name: 'Is Saturday Holiday',
        value: _cycleConfig.isSaturdayHoliday,
        onChanged: (value) {
          _cycleConfig.isSaturdayHoliday = value;
        },
      ),
      buildCheckboxOption(
        name: 'Is Sunday Holiday',
        value: _cycleConfig.isSundayHoliday,
        onChanged: (value) {
          _cycleConfig.isSundayHoliday = value;
        },
      ),
      buildSpinnerOption(
        name: 'Number of Days in a Cycle',
        value: _cycleConfig.noOfDaysInCycle,
        onChanged: (value) {
          _cycleConfig.noOfDaysInCycle = value;
        },
      ),
      buildEventsOption(
        name: "Holiday",
        events: _cycleConfig.holidays,
        addNewText: "Add Holiday",
        onAddNewPressed: (eventDate) {
          _cycleConfig.holidays.add(Event(
            id: Uuid().v1(),
            name: "New Holiday",
            skipDay: true,
            startDate: eventDate,
            endDate: eventDate,
          ));
        },
        onEventDeleted: (event) {
          _holidayIDsExpanded.remove(event.id);
          _cycleConfig.holidays.remove(event);
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
        name: "Occasions",
        events: _cycleConfig.occasions,
        addNewText: "Add Occasion",
        onAddNewPressed: (eventDate) {
          _cycleConfig.occasions.add(Event(
            id: Uuid().v1(),
            name: "New Occasion",
            skipDay: true,
            startDate: eventDate,
            endDate: eventDate,
          ));
        },
        onEventDeleted: (event) {
          _occasionIDsExpanded.remove(event.id);
          _cycleConfig.occasions.remove(event);
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
        title: Text('Cycles Editor'),
        leading: IconButton(
          icon: Icon(Icons.close),
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
                  _curCalendarInfo = _cycleConfig.getCalendar();
                  _currentView = _buildOptionView();
                });
              }
            }),
            Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select "$fieldName" on the calendar.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Divider(),
            FlatButton(
              child: Text('Cancel'),
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
}
