import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';
import 'package:spinner_input/spinner_input.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:schooler/lib/cycle_config.dart';

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
      holidays: [
        Event(
            name: 'Holiday 1',
            startDate: DateTime.utc(2019, 9, 10),
            endDate: DateTime.utc(2019, 9, 20),
            isSkipDay: true),
        Event(
            name: 'Holiday 2',
            startDate: DateTime.utc(2019, 9, 11),
            endDate: DateTime.utc(2019, 9, 11),
            isSkipDay: false),
      ],
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
        if (calendarInfo[DayInfoType.holiday] == null) {
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
        } else {
          return Column(
            children: <Widget>[
              Spacer(),
              Text(
                dateTime.day.toString(),
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.red),
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
        leading: BackButton(),
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
    Widget buildDateOption(
        {@required String name,
        @required DateTime dateTime,
        @required bool Function(DateTime) onSelected}) {
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
    Widget buildSwitchOption(
        {@required String name,
        @required bool value,
        @required void Function(bool) onChanged}) {
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
    Widget buildSpinnerOption(
        {@required String name,
        @required int value,
        @required void Function(int) onChanged}) {
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

    final scrollController =
        ScrollController(initialScrollOffset: _selectionScrollOffset);
    scrollController
        .addListener(() => _selectionScrollOffset = scrollController.offset);

    return ListView(
      controller: scrollController,
      children: <Widget>[
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
        buildSwitchOption(
          name: 'Is Saturday Holiday',
          value: _cycleConfig.isSaturdayHoliday,
          onChanged: (value) {
            _cycleConfig.isSaturdayHoliday = value;
          },
        ),
        buildSwitchOption(
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
        ExpansionTile(
          leading: Icon(Icons.date_range),
          title: Text('Holidays'),
          initiallyExpanded: _isHolidaysExpanded,
          onExpansionChanged: (isExpanded) => _isHolidaysExpanded = isExpanded,
          children: <Widget>[
            ..._cycleConfig.holidays.map(
              (event) => ExpansionTile(
                title: Text(event.name),
                leading: Icon(Icons.event),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.edit),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            FlatButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add Holiday'),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
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
