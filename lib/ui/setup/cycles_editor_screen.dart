import 'package:flutter/material.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/edit_text_screen.dart';
import 'package:schooler/ui/setup/calendar_tip_animation.dart';
import 'package:schooler/ui/setup/subject_editor_screen.dart';
import 'package:spinner_input/spinner_input.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:schooler/ui/cycle_calendar.dart';
import 'package:schooler/lib/settings.dart';

/// Local resources.
final CalendarEditorResources _R = R.calendarEditor;

/// Screen for editing cycle configuration.
class CyclesEditorScreen extends StatefulWidget {
  final void Function() onPop;

  CyclesEditorScreen({this.onPop});

  @override
  CyclesEditorScreenState createState() => CyclesEditorScreenState();
}

@visibleForTesting
class CyclesEditorScreenState extends State<CyclesEditorScreen>
    with TickerProviderStateMixin {
  /// Calendar controller for all `TableCalendar` instances.
  CalendarController _calendarController;

  /// Calendar info for the current cycle config.
  Map<DateTime, CalendarDayInfo> _curCalendarInfo;

  /// Adding event tip widget.
  Widget _tipWidget = null;

  /// A [GlobalKey] for the calendar to get its position.
  GlobalKey _calendarKey;

  /// An [AnimationController] for the one-day tip animation.
  AnimationController _oneDayTipController;

  /// The [Animation] for the one-day tip animation.
  Animation<double> _oneDayTipAnimation;

  /// A [AnimationController] for the multi-day tip animation.
  AnimationController _multiDayTipController;

  /// The [Animation] for the multi-day tip animation.
  Animation<double> _multiDayTipAnimation;

  @override
  void initState() {
    super.initState();

    if (Settings().subjects != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _donePressed();
      });
    }

    _calendarController = CalendarController();
    if (Settings().cycleConfig == null) {
      Settings().cycleConfig = _R.defaultCycleConfig;
      Settings().saveSettings();
    }

    _calendarKey = GlobalKey();

    _oneDayTipController =
        AnimationController(duration: _R.tipOneDayDuration, vsync: this);
    _multiDayTipController =
        AnimationController(duration: _R.tipMultiDayDuration, vsync: this);
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _oneDayTipController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _curCalendarInfo = Settings().cycleConfig.getCalendar();
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(_R.cyclesAppBarTitle),
            leading: BackButton(),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCalendar(
                    onSelected: _dateSelected,
                    onRangeSelected: _dateRangeSelected),
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
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _tipWidget == null,
            child: GestureDetector(
              child: Container(
                color: Colors.transparent,
                child: AnimatedSwitcher(
                  duration: _R.tipFadeDuration,
                  child: _tipWidget ?? Container(),
                ),
              ),
              onTapDown: (_) {
                _oneDayTipController.stop();
                _multiDayTipController.stop();
                setState(() => _tipWidget = null);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Create the main calendar.
  ///
  /// `onSelected` is called when a date is selected from the calendar.
  Widget _buildCalendar(
      {Future<void> Function(DateTime, Offset) onSelected,
      Future<void> Function(DateTimeRange, Offset) onRangeSelected}) {
    return CycleCalendar(
      key: _calendarKey,
      calendarController: _calendarController,
      cycleConfig: Settings().cycleConfig,
      calendarInfo: _curCalendarInfo,
      onSelected: onSelected,
      onRangeSelected: onRangeSelected,
    );
  }

  /// Create the option section.
  Widget _buildOptions() {
    return ListView(children: <Widget>[
      CheckboxListTile(
        secondary: Icon(_R.optionIcon),
        title: Text(_R.saturdayHolidayOptionText),
        value: Settings().cycleConfig.isSaturdayHoliday,
        onChanged: (value) {
          setState(() {
            Settings().cycleConfig.isSaturdayHoliday = value;
            Settings().saveSettings();
          });
        },
      ),
      CheckboxListTile(
        secondary: Icon(_R.optionIcon),
        title: Text(_R.sundayHolidayOptionText),
        value: Settings().cycleConfig.isSundayHoliday,
        onChanged: (value) {
          setState(() {
            Settings().cycleConfig.isSundayHoliday = value;
            Settings().saveSettings();
          });
        },
      ),
      ListTile(
        leading: Icon(_R.optionIcon),
        title: Text(_R.noOfDaysInCycleOptionText),
        trailing: SpinnerInput(
            disabledLongPress: true,
            spinnerValue: Settings().cycleConfig.noOfDaysInCycle.toDouble(),
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
            ),
            onChange: (value) {
              setState(() {
                Settings().cycleConfig.noOfDaysInCycle = value.toInt();
                Settings().saveSettings();
              });
            }),
      ),
      InkWell(
        child: GestureDetector(
          child: ListTile(
            leading: Icon(_R.addEventOptionIcon),
            title: Text(_R.addEventOptionText),
            trailing: Icon(_R.addEventOptionRightIcon),
          ),
          onTapUp: (details) => _showAddEventTip(details.globalPosition),
        ),
        onTap: () {},
      ),
    ]);
  }

  Future<void> _dateSelected(DateTime dateTime, Offset touchOffset) async {
    Widget contentWidget = StatefulBuilder(
      builder: (context, setState) {
        final dayInfo = _curCalendarInfo[removeTimeFrom(dateTime)];

        final isBeforeSchoolYear = removeTimeFrom(dateTime)
            .isBefore(Settings().cycleConfig.startSchoolYear);
        final isAfterSchoolYear = removeTimeFrom(dateTime)
            .isAfter(Settings().cycleConfig.endSchoolYear);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: _R.popupTopSpacing),
            Text(
              _R.dateFormat.format(dateTime),
              style: _R.getPopupDateStyle(context),
            ),
            if (dayInfo?.cycleDay != null && dayInfo?.cycle != null)
              Text(
                _R.getPopupCycleDescription(dayInfo.cycleDay, dayInfo.cycle),
                style: _R.getPopupDescriptionStyle(context),
              ),
            SizedBox(height: _R.popupDescriptionHolidaysSpacing),
            if ((dayInfo?.holidays?.isNotEmpty ?? false) &&
                dayInfo?.holidays != null)
              Text(
                _R.popupHolidayText,
                style: _R.getPopupEventTitleStyle(context),
              ),
            if ((dayInfo?.holidays?.isNotEmpty ?? false) &&
                dayInfo?.holidays != null)
              Wrap(
                spacing: _R.popupEventsWrapSpacing,
                runSpacing: _R.popupEventsWrapRunSpacing,
                children: [
                  ...dayInfo.holidays
                      .map((holiday) => Padding(
                            padding: _R.popupEventPadding,
                            child: Chip(
                              label: Text(holiday.name),
                              onDeleted: () =>
                                  _removeHoliday(holiday, setState),
                            ),
                          ))
                      .toList(),
                  IconButton(
                    icon: Icon(_R.popupEventAddIcon),
                    onPressed: () => _addHoliday(dateTime, dateTime, setState),
                  ),
                ],
              ),
            if ((dayInfo?.occasions?.isNotEmpty ?? false) &&
                dayInfo?.occasions != null)
              Text(
                _R.popupOccasionText,
                style: _R.getPopupEventTitleStyle(context),
              ),
            if ((dayInfo?.occasions?.isNotEmpty ?? false) &&
                dayInfo?.occasions != null)
              Wrap(
                spacing: _R.popupEventsWrapSpacing,
                runSpacing: _R.popupEventsWrapRunSpacing,
                children: [
                  ...dayInfo.occasions
                      .map((occasion) => Padding(
                            padding: _R.popupEventPadding,
                            child: Chip(
                              label: Text(occasion.name),
                              onDeleted: () =>
                                  _removeOccasion(occasion, setState),
                            ),
                          ))
                      .toList(),
                  IconButton(
                    icon: Icon(_R.popupEventAddIcon),
                    onPressed: () => _addOccasion(dateTime, dateTime, setState),
                  ),
                ],
              ),
            Divider(),
            if (!isBeforeSchoolYear && !isAfterSchoolYear)
              InkWell(
                child: Container(
                  height: _R.popupButtonHeight,
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    Expanded(child: Text(_R.popupSkipDayText)),
                    Checkbox(
                      value: Settings()
                          .cycleConfig
                          .skippedDays
                          .contains(removeTimeFrom(dateTime)),
                      onChanged: (_) => _toggleSkipDay(dateTime, setState),
                    ),
                  ]),
                ),
                onTap: () => _toggleSkipDay(dateTime, setState),
              ),
            if (!isAfterSchoolYear)
              InkWell(
                child: Container(
                  height: _R.popupButtonHeight,
                  alignment: Alignment.centerLeft,
                  child: Text(_R.popupStartOfYearText),
                ),
                onTap: () {
                  _setStartSchoolYear(dateTime);
                  Navigator.of(context).pop();
                },
              ),
            if (!isBeforeSchoolYear)
              InkWell(
                child: Container(
                  height: _R.popupButtonHeight,
                  alignment: Alignment.centerLeft,
                  child: Text(_R.popupEndOfYearText),
                ),
                onTap: () {
                  _setEndSchoolYear(dateTime);
                  Navigator.of(context).pop();
                },
              ),
            if (!isBeforeSchoolYear && !isAfterSchoolYear)
              InkWell(
                child: Container(
                  height: _R.popupButtonHeight,
                  alignment: Alignment.centerLeft,
                  child: Text(_R.popupAddHolidayText),
                ),
                onTap: () {
                  _addHoliday(dateTime, dateTime, setState);
                },
              ),
            if (!isBeforeSchoolYear && !isAfterSchoolYear)
              InkWell(
                child: Container(
                  height: _R.popupButtonHeight,
                  alignment: Alignment.centerLeft,
                  child: Text(_R.popupAddOccasionText),
                ),
                onTap: () {
                  _addOccasion(dateTime, dateTime, setState);
                },
              ),
          ],
        );
      },
    );

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          Rect.fromLTWH(touchOffset.dx, touchOffset.dy, 0, 0),
          Rect.fromLTWH(0, 0, 100000, 1000000)),
      items: [
        PopupMenuItem(
          enabled: false,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.subtitle1,
            child: contentWidget,
          ),
        ),
      ],
    );
  }

  Future<void> _dateRangeSelected(
      DateTimeRange range, Offset touchOffset) async {
    final contentWidget = StatefulBuilder(
      builder: (context, setState) {
        final Set<Event> holidays = () {
          Set<Event> result = _curCalendarInfo[removeTimeFrom(range.start)]
                  ?.holidays
                  ?.toSet() ??
              {};
          for (DateTime dateTime = removeTimeFrom(range.start);
              !dateTime.isAfter(range.end);
              dateTime = dateTime.add(Duration(days: 1))) {
            result = result.intersection(
                _curCalendarInfo[dateTime]?.holidays?.toSet() ?? {});
            if (result.isEmpty) break;
          }
          return result;
        }();

        final Set<Event> occasions = () {
          Set<Event> result = _curCalendarInfo[removeTimeFrom(range.start)]
                  ?.occasions
                  ?.toSet() ??
              {};
          for (DateTime dateTime = removeTimeFrom(range.start);
              !dateTime.isAfter(range.end);
              dateTime = dateTime.add(Duration(days: 1))) {
            result = result.intersection(
                _curCalendarInfo[dateTime]?.occasions?.toSet() ?? {});
            if (result.isEmpty) break;
          }
          return result;
        }();

        final bool isSkipDay = () {
          // If the day is out of the school year, it is not shown and handled in the `if` logic.
          bool result = Settings()
              .cycleConfig
              .skippedDays
              .contains(removeTimeFrom(range.start));
          for (DateTime dateTime = removeTimeFrom(range.start);
              !dateTime.isAfter(range.end);
              dateTime = dateTime.add(Duration(days: 1))) {
            if (result !=
                Settings()
                    .cycleConfig
                    .skippedDays
                    .contains(removeTimeFrom(dateTime))) {
              return null;
            }
          }
          return result;
        }();

        final isBeforeSchoolYear = removeTimeFrom(range.start)
            .isBefore(Settings().cycleConfig.startSchoolYear);
        final isAfterSchoolYear = removeTimeFrom(range.end)
            .isAfter(Settings().cycleConfig.endSchoolYear);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: _R.popupTopSpacing),
            Text(
              _R.getPopupRangeDescription(range),
              style: _R.getPopupDateStyle(context),
            ),
            SizedBox(height: _R.popupDescriptionHolidaysSpacing),
            if (holidays.isNotEmpty)
              Text(
                _R.popupHolidayText,
                style: _R.getPopupEventTitleStyle(context),
              ),
            if (holidays.isNotEmpty)
              Wrap(
                spacing: _R.popupEventsWrapSpacing,
                runSpacing: _R.popupEventsWrapRunSpacing,
                children: [
                  ...holidays
                      .map((holiday) => Padding(
                            padding: _R.popupEventPadding,
                            child: Chip(
                              label: Text(holiday.name),
                              onDeleted: () =>
                                  _removeHoliday(holiday, setState),
                            ),
                          ))
                      .toList(),
                  IconButton(
                    icon: Icon(_R.popupEventAddIcon),
                    onPressed: () =>
                        _addHoliday(range.start, range.end, setState),
                  ),
                ],
              ),
            if (occasions.isNotEmpty)
              Text(
                _R.popupOccasionText,
                style: _R.getPopupEventTitleStyle(context),
              ),
            if (occasions.isNotEmpty)
              Wrap(
                spacing: _R.popupEventsWrapSpacing,
                runSpacing: _R.popupEventsWrapRunSpacing,
                children: [
                  ...occasions
                      .map((occasion) => Padding(
                            padding: _R.popupEventPadding,
                            child: Chip(
                              label: Text(occasion.name),
                              onDeleted: () =>
                                  _removeOccasion(occasion, setState),
                            ),
                          ))
                      .toList(),
                  IconButton(
                    icon: Icon(_R.popupEventAddIcon),
                    onPressed: () =>
                        _addOccasion(range.start, range.end, setState),
                  ),
                ],
              ),
            ...((isBeforeSchoolYear || isAfterSchoolYear)
                ? [SizedBox(height: _R.popupNoOptionBottomSpacing)]
                : [
                    Divider(),
                    InkWell(
                      child: Container(
                        height: _R.popupButtonHeight,
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          Expanded(child: Text(_R.popupSkipDayText)),
                          Checkbox(
                            tristate: true,
                            value: isSkipDay,
                            onChanged: (_) => _setRangeSkipDay(
                                !(isSkipDay ?? false),
                                range.start,
                                range.end,
                                setState),
                          ),
                        ]),
                      ),
                      onTap: () => _setRangeSkipDay(!(isSkipDay ?? false),
                          range.start, range.end, setState),
                    ),
                    InkWell(
                      child: Container(
                        height: _R.popupButtonHeight,
                        alignment: Alignment.centerLeft,
                        child: Text(_R.popupAddHolidayText),
                      ),
                      onTap: () {
                        _addHoliday(range.start, range.end, setState);
                      },
                    ),
                    InkWell(
                      child: Container(
                        height: _R.popupButtonHeight,
                        alignment: Alignment.centerLeft,
                        child: Text(_R.popupAddOccasionText),
                      ),
                      onTap: () {
                        _addOccasion(range.start, range.end, setState);
                      },
                    ),
                  ]),
          ],
        );
      },
    );

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          Rect.fromLTWH(touchOffset.dx, touchOffset.dy, 0, 0),
          Rect.fromLTWH(0, 0, 100000, 1000000)),
      items: [
        PopupMenuItem(
          enabled: false,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.subtitle1,
            child: contentWidget,
          ),
        ),
      ],
    );
  }

  // TODO: Change name
  void _showAddEventTip(Offset touchOffset) {
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
          Rect.fromLTWH(touchOffset.dx, touchOffset.dy, 0, 0),
          Rect.fromLTWH(0, 0, 100000, 1000000)),
      items: [
        PopupMenuItem(
          child: Text(_R.addEventPopupOneText),
          value: 'one',
        ),
        PopupMenuItem(
          child: Text(_R.addEventPopupMultiText),
          value: 'multi',
        ),
      ],
    ).then((val) {
      if (val == null) return;

      if (val == 'one') {
        _setOneDayTip();
      } else if (val == 'multi') {
        _setMultiDayTip();
      }
      setState(() {});
    });
  }

  void _setOneDayTip() {
    final RenderBox calendarBox =
        _calendarKey.currentContext.findRenderObject();
    final calendarPos = calendarBox.localToGlobal(Offset.zero);
    final calendarSize = calendarBox.size;

    _oneDayTipController.reset();
    _oneDayTipController.repeat();
    _oneDayTipAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_oneDayTipController);
    _tipWidget = Stack(
      key: UniqueKey(),
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: calendarPos.dy,
          child: Center(
            child: Material(
              elevation: _R.tipElevation,
              child: Padding(
                padding: _R.tipPadding,
                child: Text(
                  _R.tipOneDayText,
                  textAlign: TextAlign.center,
                  style: _R.getTipStyle(context),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: calendarPos.dy,
          height: calendarSize.height,
          child: Center(
            child: AnimatedBuilder(
              animation: _oneDayTipAnimation,
              builder: (context, _) {
                final data = CalendarOneDayTipAnimation.fromTime(
                    _oneDayTipAnimation.value);

                return Opacity(
                  opacity: data.opacity,
                  child: Material(
                    shape: CircleBorder(
                        side: BorderSide(color: _R.tipCircleBorderColor)),
                    animationDuration: Duration.zero,
                    elevation: data.elevation,
                    color: _R.tipCircleFillColor,
                    child: Container(
                      width: data.size,
                      height: data.size,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _setMultiDayTip() {
    final RenderBox calendarBox =
        _calendarKey.currentContext.findRenderObject();
    final calendarPos = calendarBox.localToGlobal(Offset.zero);
    final calendarSize = calendarBox.size;

    _multiDayTipController.reset();
    _multiDayTipController.repeat();
    _multiDayTipAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_multiDayTipController);
    _tipWidget = Stack(
      key: UniqueKey(),
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: calendarPos.dy,
          child: Center(
            child: Material(
              elevation: _R.tipElevation,
              child: Padding(
                padding: _R.tipPadding,
                child: Text(
                  _R.tipMultiDayText,
                  textAlign: TextAlign.center,
                  style: _R.getTipStyle(context),
                ),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _multiDayTipAnimation,
          builder: (context, _) {
            final data = CalendarMultiDayTipAnimation.fromTime(
                _multiDayTipAnimation.value);

            return Positioned(
              left: calendarSize.width * data.posX - data.size / 2,
              top: calendarPos.dy +
                  calendarSize.height * data.posY -
                  data.size / 2,
              width: data.size,
              height: data.size,
              child: Opacity(
                opacity: data.opacity,
                child: Material(
                  shape: CircleBorder(
                      side: BorderSide(color: _R.tipCircleBorderColor)),
                  animationDuration: Duration.zero,
                  elevation: data.elevation,
                  color: _R.tipCircleFillColor,
                  child: Container(
                    width: data.size,
                    height: data.size,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _toggleSkipDay(DateTime dateTime, StateSetter setState) {
    // List.remove returns true if the item is in the list.
    if (!Settings().cycleConfig.skippedDays.remove(removeTimeFrom(dateTime))) {
      Settings().cycleConfig.skippedDays.add(removeTimeFrom(dateTime));
    }
    Settings().saveSettings();
    setState(() {});
    this.setState(() {});
  }

  void _setRangeSkipDay(
      bool value, DateTime start, DateTime end, StateSetter setState) {
    for (DateTime dateTime = removeTimeFrom(start);
        !dateTime.isAfter(end);
        dateTime = dateTime.add(Duration(days: 1))) {
      if (value) {
        if (!Settings()
            .cycleConfig
            .skippedDays
            .contains(removeTimeFrom(dateTime))) {
          Settings().cycleConfig.skippedDays.add(removeTimeFrom(dateTime));
        }
      } else {
        Settings().cycleConfig.skippedDays.remove(removeTimeFrom(dateTime));
      }
    }

    Settings().saveSettings();
    setState(() {});
    this.setState(() {});
  }

  void _addHoliday(DateTime start, DateTime end, StateSetter setState) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditTextScreen(
        title: _R.eventNameText,
        value: _R.newHolidayName,
        onDone: (name) {
          _calendarController.setFocusedDay(removeTimeFrom(start));
          Settings().cycleConfig.holidays.add(Event(
                id: Event.generateID(),
                name: name,
                startDate: removeTimeFrom(start),
                endDate: removeTimeFrom(end),
              ));
          Settings().saveSettings();
          setState(() {});
          this.setState(() {});
        },
      ),
    ));
  }

  void _addOccasion(DateTime start, DateTime end, StateSetter setState) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditTextScreen(
        title: _R.eventNameText,
        value: _R.newOccasionName,
        onDone: (name) {
          _calendarController.setFocusedDay(removeTimeFrom(start));
          Settings().cycleConfig.occasions.add(Event(
                id: Event.generateID(),
                name: name,
                startDate: removeTimeFrom(start),
                endDate: removeTimeFrom(end),
              ));
          Settings().saveSettings();
          setState(() {});
          this.setState(() {});
        },
      ),
    ));
  }

  void _removeHoliday(Event holiday, StateSetter setState) {
    Settings().cycleConfig.holidays.remove(holiday);
    Settings().saveSettings();
    setState(() {});
    this.setState(() {});
  }

  void _removeOccasion(Event occasion, StateSetter setState) {
    Settings().cycleConfig.occasions.remove(occasion);
    Settings().saveSettings();
    setState(() {});
    this.setState(() {});
  }

  void _setStartSchoolYear(DateTime dateTime) {
    setState(() {
      Settings().cycleConfig.startSchoolYear = removeTimeFrom(dateTime);
      Settings().saveSettings();
    });
  }

  void _setEndSchoolYear(DateTime dateTime) {
    setState(() {
      Settings().cycleConfig.endSchoolYear = removeTimeFrom(dateTime);
      Settings().saveSettings();
    });
  }

  /// When "Done" button is pressed, navigate to `timetableEditorScreen`.
  void _donePressed() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SubjectEditorScreen(onPop: () {
              Settings().subjects = null;
              Settings().saveSettings();
            })));
  }
}
