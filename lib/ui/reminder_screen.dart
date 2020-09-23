import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:schooler/lib/geofencing.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/region_picker.dart';
import 'package:schooler/ui/edit_text_screen.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:schooler/ui/suggestion_text_field.dart';
import 'package:schooler/ui/time_picker.dart';
import 'package:url_launcher/url_launcher.dart';

final ReminderScreenResources _R = R.reminderScreen;

class ReminderScreen extends StatefulWidget {
  final Reminder reminder;

  ReminderScreen({Key key, this.reminder}) : super(key: key);

  @override
  ReminderScreenState createState() => ReminderScreenState();
}

class ReminderScreenState extends State<ReminderScreen> {
  TextEditingController _nameController;

  Widget _triggerOptionsWidget;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.reminder.name);
  }

  @override
  Widget build(BuildContext context) {
    _triggerOptionsWidget ??= _buildTriggerOptions();
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_R.appBarTitle),
          actions: [
            IconButton(
              icon: Icon(_R.deleteIcon),
              tooltip: _R.deleteTooltip,
              onPressed: _deletePressed,
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: Settings().reminderListener,
          builder: (context, _, __) => ListView(
            padding: _R.listViewPadding,
            children: <Widget>[
              _buildRow(
                // Name
                leading: Icon(
                  _R.reminderIcon,
                  size: _R.reminderIconSize,
                ),
                child: TextField(
                  style: _R.getNameTextStyle(context),
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: _R.nameHintText,
                  ),
                  onChanged: _nameOnChanged,
                ),
              ),
              SizedBox(height: _R.nameEnabledSpacing),
              _buildRow(
                leading: Container(),
                child: Row(children: [
                  Expanded(
                    child: Text(_R.enabledText),
                  ),
                  Switch(
                    value: widget.reminder.enabled,
                    onChanged: _enabledOnChanged,
                  ),
                ]),
              ),
              SizedBox(height: _R.enabledSubjectSpacing),
              _buildRow(
                // Subject
                leading: Icon(
                  _R.subjectIcon,
                  color: _R.iconColor,
                ),
                child: InkWell(
                  child: widget.reminder.subject == null
                      ? Container(
                          height: _R.subjectHeight,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: _R.subjectPlaceholderPadding,
                              child: Text(
                                _R.subjectPlaceholder,
                                style: _R.subjectPlaceholderTextStyle(context),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: _R.subjectHeight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: SubjectBlock(
                                  name: widget.reminder.subject.name,
                                  color: widget.reminder.subject.color,
                                ),
                              ),
                              SizedBox(width: _R.subjectBlockEditSpacing),
                              Icon(
                                _R.subjectEditIcon,
                                color: _R.subjectIconColor,
                              ),
                              SizedBox(width: _R.subjectEditRemoveSpacing),
                              InkWell(
                                child: Icon(
                                  _R.subjectRemoveIcon,
                                  color: _R.subjectIconColor,
                                ),
                                onTap: _subjectRemoved,
                              ),
                            ],
                          ),
                        ),
                  onTap: _subjectTapped,
                ),
              ),
              SizedBox(height: _R.subjectTriggerSpacing),
              _buildRow(
                // Trigger type
                leading: Container(),
                child: Wrap(
                  runSpacing: _R.triggerTypeVerticalSpacing,
                  spacing: _R.triggerTypeHorizontalSpacing,
                  children: <Widget>[
                    ChoiceChip(
                      label: Text(_R.triggerTypeNullText),
                      selected: widget.reminder.trigger == null,
                      onSelected: (value) {
                        if (value) _triggerTypeChanged(null);
                      },
                    ),
                    ChoiceChip(
                      avatar: Icon(
                        _R.triggerTypeTimeIcon,
                        size: _R.triggerTypeIconSize,
                      ),
                      label: Text(_R.triggerTypeTimeText),
                      selected: widget.reminder.trigger is TimeReminderTrigger,
                      onSelected: (value) {
                        if (value) _triggerTypeChanged(TimeReminderTrigger);
                      },
                    ),
                    ChoiceChip(
                      avatar: Icon(
                        _R.triggerTypeLocationIcon,
                        size: _R.triggerTypeIconSize,
                      ),
                      label: Text(_R.triggerTypeLocationText),
                      selected:
                          widget.reminder.trigger is LocationReminderTrigger,
                      onSelected: (value) {
                        if (value) _triggerTypeChanged(LocationReminderTrigger);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: _R.triggerTypeOptionsSpacing),
              AnimatedSwitcher(
                duration: _R.triggerOptionsSwitchDuration,
                switchInCurve: _R.triggerOptionsSwitchCurve,
                switchOutCurve: _R.triggerOptionsSwitchCurve,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      child: child,
                      sizeFactor: animation,
                    ),
                  );
                },
                child: _triggerOptionsWidget,
              ),
              SizedBox(height: _R.triggerOptionsNotesSpacing),
              _buildRow(
                leading: Icon(
                  _R.notesIcon,
                  color: _R.iconColor,
                ),
                child: InkWell(
                  onTap: _notesTapped,
                  child: Padding(
                    padding: _R.notesPadding,
                    child: widget.reminder.notes == null ||
                            widget.reminder.notes == ''
                        ? Text(
                            _R.notesPlaceholder,
                            style: _R.getNotesPlaceholderTextStyle(context),
                          )
                        : Builder(
                            builder: (context) => Linkify(
                              onOpen: (link) => _notesURLTapped(context, link),
                              text: widget.reminder.notes,
                              options: LinkifyOptions(humanize: false),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        _onWillPop();
        return true;
      },
    );
  }

  /// From AssignmentScreen
  Widget _buildRow({Widget leading, Widget child}) {
    return Row(children: <Widget>[
      SizedBox(
        width: _R.iconColumnWidth,
        child: Align(
          alignment: Alignment.centerLeft,
          child: leading,
        ),
      ),
      Expanded(child: child),
    ]);
  }

  Widget _buildTriggerOptions() {
    final trigger = widget.reminder.trigger;
    if (trigger == null) {
      return Container(key: ValueKey(null));
    } else if (trigger is TimeReminderTrigger) {
      final dateTimeRow = _buildRow(
        leading: Icon(
          _R.triggerTypeTimeIcon,
          color: _R.iconColor,
        ),
        child: Builder(
          builder: (context) {
            if (trigger.dateTime == null) {
              return InkWell(
                child: Container(
                  height: _R.timeOptionsDateTimeHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: _R.timeOptionsDateTimePlaceholderPadding,
                      child: Text(
                        _R.timeOptionsDateTimePlaceholder,
                        style: _R.getTimeOptionsDateTimePlaceholderTextStyle(
                            context),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                height: _R.timeOptionsDateTimeHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Padding(
                          padding: _R.timeOptionsDatePadding,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _R.timeOptionsDateFormat.format(trigger.dateTime),
                            ),
                          ),
                        ),
                        onTap: _timeTriggerDatePressed,
                      ),
                    ),
                    InkWell(
                      child: Row(children: <Widget>[
                        Padding(
                          padding: _R.timeOptionsTimePadding,
                          child: Text(_R.timeOptionsTimeFormat
                              .format(trigger.dateTime)),
                        ),
                        SizedBox(width: _R.timeOptionsTimeEditSpacing),
                        Icon(
                          _R.timeOptionsEditIcon,
                          color: _R.timeOptionsEditIconColor,
                        ),
                      ]),
                      onTap: _timeTriggerTimePressed,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );

      final repeatRow = _buildRow(
        leading: Icon(
          _R.timeRepeatIcon,
          color: _R.iconColor,
        ),
        child: InkWell(
          child: Container(
            height: _R.timeRepeatHeight,
            child: trigger.repeat == null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: _R.timeRepeatPadding,
                      child: Text(
                        _R.timeRepeatPlaceholder,
                        style: _R.getTimeRepeatPlaceholderTextStyle(context),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: _R.timeRepeatPadding,
                            child:
                                Text(_R.timeRepeatTimeToString(trigger.repeat)),
                          ),
                        ),
                      ),
                      Icon(
                        _R.timeRepeatEditIcon,
                        color: _R.timeRepeatEditIconColor,
                      ),
                    ],
                  ),
          ),
          onTap: _timeTriggerRepeatPressed,
        ),
      );

      return Column(
        key: ValueKey(TimeReminderTrigger),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          dateTimeRow,
          SizedBox(height: _R.timeOptionsRepeatSpacing),
          repeatRow,
        ],
      );
    } else if (trigger is LocationReminderTrigger) {
      final geofenceEventString = _R.geofenceEventName[trigger.geofenceEvent];

      final location = trigger.region?.location;
      String locationDescription;
      if (location == null) {
        locationDescription = '';
      } else {
        locationDescription =
            location.getUserDescription(geocoderCompletion: (addresses) {
          setState(() {
            widget.reminder.register();
            Settings().reminderListener.notifyListeners();
            _triggerOptionsWidget = _buildTriggerOptions();
          });
        });
      }

      return Container(
        key: ValueKey(LocationReminderTrigger),
        child: _buildRow(
          leading: Icon(
            _R.triggerTypeLocationIcon,
            color: _R.iconColor,
          ),
          child: Container(
            height: _R.locationOptionsHeight,
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: _R.locationOptionsPadding,
                      child: trigger.region == null
                          ? Text(
                              _R.locationOptionsPlaceholder,
                              style: _R.getLocationOptionsPlaceholderTextStyle(
                                  context),
                            )
                          : Text(
                              _R.getLocationOptionsText(
                                  geofenceEventString, locationDescription),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                    ),
                  ),
                  Icon(
                    _R.locationOptionsEditIcon,
                    color: _R.locationOptionsEditIconColor,
                  ),
                ],
              ),
              onTap: _locationTriggerSelectPressed,
            ),
          ),
        ),
      );
    } else {
      assert(false, 'Unknown subtype of ReminderTrigger');
      return Container();
    }
  }

  void _nameOnChanged(String value) {
    widget.reminder.name = value;
    _triggerOptionsWidget = _buildTriggerOptions();
    widget.reminder.register();
    Settings().reminderListener.notifyListeners();
    Settings().saveSettings();
  }

  void _enabledOnChanged(bool value) {
    final oriEnabled = widget.reminder.enabled;
    widget.reminder.enabled = value;
    _triggerOptionsWidget = _buildTriggerOptions();
    widget.reminder.register().then((_) {
      Settings().reminderListener.notifyListeners();
      Settings().saveSettings();
    }).catchError((error) {
      widget.reminder.enabled = oriEnabled;
      Settings().reminderListener.notifyListeners();
      _showGeofenceError(error).then((_) {
        if (error is GeofenceMaximumRadiusReachedException ||
            error is GeofenceUnknownException ||
            error is! GeofenceException) {
          _locationTriggerSelectPressed();
        }
      });
    });
  }

  void _subjectRemoved() {
    widget.reminder.subject = null;
    _triggerOptionsWidget = _buildTriggerOptions();
    widget.reminder.register();
    Settings().reminderListener.notifyListeners();
    Settings().saveSettings();
  }

  void _subjectTapped() {
    SuggestionTextField.showSubjectPicker(
      context,
      subjectIcon: _R.subjectIcon,
      minItemForListView: _R.subjectPickerMinItemForListView,
      listViewHeight: _R.subjectPickerListViewHeight,
      onDone: (subject) {
        widget.reminder.subject = subject;
        _triggerOptionsWidget = _buildTriggerOptions();
        widget.reminder.register();
        Settings().reminderListener.notifyListeners();
        Settings().saveSettings();
      },
    );
  }

  /// `triggerType` can either be null, TimeReminderTrigger, or LocationReminderTrigger
  void _triggerTypeChanged(Type triggerType) {
    if (triggerType == null) {
      widget.reminder.trigger = null;
    } else if (triggerType == TimeReminderTrigger) {
      widget.reminder.trigger = TimeReminderTrigger(dateTime: DateTime.now());
    } else if (triggerType == LocationReminderTrigger) {
      bool showingDialog = false;
      Geofencing.requestPermission(iOSAlwaysPermissionCallback: () {
        if (showingDialog) Navigator.of(context).pop();
      }).then((permission) {
        if (!permission) {
          showingDialog = true;
          _showGeofenceError(GeofencePermissionDeniedException(''))
              .then((_) => showingDialog = false);
        }
      });

      widget.reminder.trigger =
          LocationReminderTrigger(geofenceEvent: GeofenceEvent.enter);
    } else {
      assert(false, 'Unknown triggerType');
    }
    _triggerOptionsWidget = _buildTriggerOptions();
    widget.reminder.register();
    Settings().reminderListener.notifyListeners();
    Settings().saveSettings();
  }

  void _timeTriggerDatePressed() {
    SuggestionTextField.showDatePicker(
      context,
      subject: widget.reminder.subject,
      onDone: (date) {
        Navigator.pop(context);

        if (widget.reminder.trigger is! TimeReminderTrigger) {
          throw Exception(
              'Date picker for a time-based trigger is being closed but the trigger type is not TimeReminderTrigger.');
        }
        final curDateTime =
            (widget.reminder.trigger as TimeReminderTrigger).dateTime;

        (widget.reminder.trigger as TimeReminderTrigger).dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            curDateTime.hour,
            curDateTime.minute);
        _triggerOptionsWidget = _buildTriggerOptions();
        widget.reminder.register();
        Settings().reminderListener.notifyListeners();
        Settings().saveSettings();
      },
    );
  }

  void _timeTriggerTimePressed() {
    DatePicker.showPicker(context,
        showTitleActions: true,
        pickerModel: TimePicker.normal(
            currentTime: (widget.reminder.trigger as TimeReminderTrigger)
                .dateTime), onConfirm: (DateTime time) {
      final curDateTime =
          (widget.reminder.trigger as TimeReminderTrigger).dateTime;

      (widget.reminder.trigger as TimeReminderTrigger).dateTime = DateTime(
          curDateTime.year,
          curDateTime.month,
          curDateTime.day,
          time.hour,
          time.minute);
      _triggerOptionsWidget = _buildTriggerOptions();
      widget.reminder.register();
      Settings().reminderListener.notifyListeners();
      Settings().saveSettings();
    });
  }

  void _timeTriggerRepeatPressed() async {
    Future<T> showDialog<T>(List<Widget> children) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                  pressedOpacity: _R.repeatPickerCancelPressedOpacity,
                  padding: _R.repeatPickerCancelPadding,
                  child: Text(
                    _R.repeatPickerCancelText,
                    style: _R.repeatPickerCancelTextStyle,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              ...children,
            ]),
          ),
        ),
      );
    }

    bool isDismissed = true;
    var repeat = await showDialog<TimeReminderRepeat>(
      [
        null,
        TimeReminderRepeat.day,
        TimeReminderRepeat.weekDay(1),
        if (Settings().calendarType == CalendarType.cycle)
          TimeReminderRepeat.timetableDay(TimetableCycleDay(1)),
        TimeReminderRepeat.month,
        TimeReminderRepeat.year,
      ]
          .map((repeat) => ListTile(
                leading: Icon(Icons.repeat),
                title: Text(_R.repeatPickerChoicesText[repeat] ?? ''),
                trailing: (repeat?.getWeekDay() != null ||
                        repeat?.getTimetableDay() != null)
                    ? Icon(_R.repeatPickerArrowIcon)
                    : null,
                onTap: () {
                  isDismissed = false;
                  Navigator.pop(context, repeat);
                },
              ))
          .toList(),
    );
    if (isDismissed) return;

    if (repeat?.getWeekDay() != null) {
      final weekday = await showDialog<int>(
        List.generate(
            7,
            (int weekdayMinusOne) => ListTile(
                  title: Text(_R.repeatPickerWeekdayText[weekdayMinusOne]),
                  onTap: () => Navigator.pop(context, weekdayMinusOne + 1),
                )),
      );

      if (weekday == null) return;
      repeat = TimeReminderRepeat.weekDay(weekday);
    } else if (repeat?.getTimetableDay() != null) {
      final cycleDay = await showDialog<TimetableDay>(Settings()
          .timetable
          .days
          .map((timetableDay) => ListTile(
                title: Text(_R.timetableDayToString(timetableDay)),
                onTap: () => Navigator.pop(context, timetableDay),
              ))
          .toList());

      if (cycleDay == null) return;
      repeat = TimeReminderRepeat.timetableDay(cycleDay);
    }

    (widget.reminder.trigger as TimeReminderTrigger).repeat = repeat;
    _triggerOptionsWidget = _buildTriggerOptions();
    widget.reminder.register();
    Settings().reminderListener.notifyListeners();
    Settings().saveSettings();
  }

  void _locationTriggerSelectPressed() {
    assert(widget.reminder.trigger is LocationReminderTrigger);
    RegionPicker.showPicker(context, trigger: widget.reminder.trigger)
        .then((trigger) {
      if (trigger != null) {
        final oriTrigger =
            LocationReminderTrigger.fromJSON(widget.reminder.trigger.toJSON());
        widget.reminder.trigger = trigger;
        _triggerOptionsWidget = _buildTriggerOptions();
        widget.reminder.register().then((_) {
          Settings().reminderListener.notifyListeners();
          Settings().saveSettings();
        }).catchError((error) {
          widget.reminder.trigger = oriTrigger;
          Settings().reminderListener.notifyListeners();
          _showGeofenceError(error).then((_) {
            if (error is GeofenceMaximumRadiusReachedException ||
                error is GeofenceUnknownException ||
                error is! GeofenceException) {
              _locationTriggerSelectPressed();
            }
          });
        });
      }
    });
  }

  void _notesURLTapped(BuildContext context, LinkableElement link) async {
    try {
      if (await canLaunch(link.url)) {
        await launch(link.url);
      } else {
        throw Exception();
      }
    } catch (e) {
      print(e);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(_R.getNotesURLError(link.url)),
      ));
    }
  }

  void _notesTapped() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditTextScreen(
              title: _R.notesEditTextScreenTitle,
              value: widget.reminder.notes ?? '',
              maxLines: null,
              onDone: (text) {
                widget.reminder.notes = text;
                _triggerOptionsWidget = _buildTriggerOptions();
                widget.reminder.register();
                Settings().reminderListener.notifyListeners();
                Settings().saveSettings();
              },
            )));
  }

  void _deletePressed() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_R.deleteTitle),
        content: Text(_R.deleteContent),
        actions: <Widget>[
          FlatButton(
            child: Text(_R.deleteCancelText),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text(_R.deleteConfirmText),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ).then((shouldDelete) {
      // Not `if (shouldDelete)` because it might be null
      if (shouldDelete == true) {
        Settings().reminders.remove(widget.reminder);
        widget.reminder.unregister();
        Settings().reminderListener.notifyListeners();
        Settings().saveSettings();

        // Go to previous page
        Navigator.pop(context);
      }
    });
  }

  Future<void> _showGeofenceError(dynamic exception) async {
    Future<void> showAlert({
      @required String title,
      @required String content,
      @required List<Widget> actions,
    }) =>
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: actions,
          ),
        );

    Widget buildOKButton() => FlatButton(
          child: Text(_R.geofenceErrorConfirmText),
          onPressed: () => Navigator.pop(context),
        );

    switch (exception.runtimeType) {
      case GeofencePermissionDeniedException:
        await showAlert(
          title: _R.geofenceErrorPermissionTitle,
          content: _R.geofenceErrorPermissionContent,
          actions: <Widget>[
            FlatButton(
              child: Text(_R.geofenceErrorPermissionSettingsText),
              onPressed: () {
                Geofencing.openAppsSettings();
                Navigator.pop(context);
              },
            ),
            buildOKButton(),
          ],
        );
        break;
      case GeofenceUnavailableException:
        await showAlert(
          title: _R.geofenceErrorUnavailableTitle,
          content: _R.geofenceErrorUnavailableContent,
          actions: [buildOKButton()],
        );
        break;
      case GeofenceMaximumRadiusReachedException:
        await showAlert(
          title: _R.geofenceErrorRadiusTitle,
          content: _R.geofenceErrorRadiusContent,
          actions: [buildOKButton()],
        );
        break;
      case GeofenceMaximumGeofencesReachedException:
        await showAlert(
          title: _R.geofenceErrorGeofencesNoTitle,
          content: _R.geofenceErrorGeofencesNoContent,
          actions: [buildOKButton()],
        );
        break;
      case GeofenceUnknownException:
        await showAlert(
          title: _R.geofenceUnknownTitle,
          content: (exception as GeofenceUnknownException).message ?? '',
          actions: [buildOKButton()],
        );
        break;
      default:
        await showAlert(
          title: _R.geofenceUnknownTitle,
          content: exception.toString(),
          actions: [buildOKButton()],
        );
        break;
    }
  }

  void _onWillPop() {
    bool isEmptyOrNull(String str) => str == null || str == '';
    if (isEmptyOrNull(widget.reminder.name) &&
        isEmptyOrNull(widget.reminder.notes) &&
        widget.reminder.subject == null &&
        widget.reminder.trigger == null) {
      // Reminder is considered empty. Remove it.
      Settings().reminders.remove(widget.reminder);
      widget.reminder.unregister();
      Settings().reminderListener.notifyListeners();
      Settings().saveSettings();
    }
    Navigator.pop(context);
  }
}
