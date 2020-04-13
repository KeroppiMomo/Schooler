import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/main_tabs/wwidgets/wwidget.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:geofencing/geofencing.dart';

final RemindersWWidgetReosurces _R = R.remindersWWidget;

class RemindersWWidget extends StatefulWidget {
  @override
  RemindersWWidgetState createState() => RemindersWWidgetState();
}

class RemindersWWidgetState extends State<RemindersWWidget> {
  @override
  void initState() {
    super.initState();

    final testReminders = [
      Reminder(
        id: '0001',
        name: 'Call John',
        trigger: TimeReminderTrigger(dateTime: DateTime(2020, 4, 20)),
      ),
      Reminder(
        id: '0002',
        name: 'Call Mary',
        subject: Subject('English', color: Colors.red),
        enabled: false,
        trigger: TimeReminderTrigger(dateTime: DateTime(2019, 12, 31)),
      ),
      Reminder(
        id: '0003',
        name: 'Take Workbook',
        trigger: LocationReminderTrigger(
          geofenceEvent: GeofenceEvent.enter,
          region: LocationReminderRegion(
            name: 'Home',
            latitude: 22.4487838,
            longitude: 114.0698347,
            radius: 200,
          ),
        ),
      ),
      Reminder(
        id: '0004',
        name: 'Take Textbook from locker',
        trigger: LocationReminderTrigger(
          geofenceEvent: GeofenceEvent.exit,
          region: LocationReminderRegion(
            name: 'School',
            latitude: 22.4487838,
            longitude: 114.0698347,
            radius: 200,
          ),
        ),
      ),
    ];

    Settings().reminders = testReminders;
  }

  @override
  Widget build(BuildContext context) {
    return WWidget(
      title: _R.wwidgetTitle,
      icon: _R.wwidgetIcon,
      contentPadding: _R.wwidgetPadding,
      onSettingsPressed: _settingsPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ...(Settings().reminders ?? []).map(_buildReminder).toList(),
          FlatButton.icon(
            icon: Icon(_R.addIcon),
            label: Text(_R.addText),
            onPressed: _addPressed,
          ),
          FlatButton.icon(
            icon: Icon(_R.viewIcon),
            label: Text(_R.viewText),
            onPressed: _viewPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildReminder(Reminder reminder) {
    final String triggerString = () {
      if (reminder.trigger is LocationReminderTrigger) {
        final trigger = reminder.trigger as LocationReminderTrigger;
        final region = trigger.region;

        return _R.reminderGeofenceEventString[trigger.geofenceEvent] +
            (region.name ??
                _R.reminderLatLongFormat(region.latitude, region.longitude));
      } else if (reminder.trigger is TimeReminderTrigger) {
        final dateTime = (reminder.trigger as TimeReminderTrigger).dateTime;
        return _R.reminderDateFormat.format(dateTime);
      } else {
        assert(false, 'Unknown subtype of ReminderTrigger');
        return '';
      }
    }();

    final IconData triggerIcon = {
      LocationReminderTrigger: Icons.location_on,
      TimeReminderTrigger: Icons.alarm,
    }[reminder.trigger.runtimeType];

    return InkWell(
      child: Opacity(
        opacity: reminder.enabled ? 1.0 : _R.reminderDisabledOpacity,
        child: Padding(
          padding: _R.reminderPadding,
          child: Table(
            columnWidths: {0: FixedColumnWidth(_R.reminderIconColumnWidth)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: _R.reminderIconPadding,
                    child: Icon(
                      reminder.enabled
                          ? _R.reminderIconEnable
                          : _R.reminderIconDisabled,
                      size: _R.reminderIconSize,
                    ),
                  ),
                ),
                reminder.subject == null
                    ? Text(
                        reminder.name,
                        overflow: TextOverflow.ellipsis,
                        style: _R.reminderTitleTextStyle(context),
                      )
                    : Row(children: <Widget>[
                        SubjectBlock(
                          name: reminder.subject.name,
                          color: reminder.subject.color,
                        ),
                        SizedBox(width: _R.reminderSubjectTitleSpacing),
                        Expanded(
                          child: Text(
                            reminder.name,
                            overflow: TextOverflow.ellipsis,
                            style: _R.reminderTitleTextStyle(context),
                          ),
                        ),
                      ]),
              ]),
              TableRow(children: [
                Container(),
                Row(
                  children: [
                    Icon(
                      triggerIcon,
                      color: _R.reminderTriggerIconColor,
                      size: _R.reminderTriggerIconSize,
                    ),
                    SizedBox(width: _R.reminderTriggerIconTextSpacing),
                    Text(
                      triggerString,
                      style: _R.reminderTriggerTextStyle(context),
                    ),
                  ],
                ),
              ]),
            ],
          ),
        ),
      ),
      onTap: () => _reminderPressed(reminder),
    );
  }

  void _settingsPressed() {}

  void _addPressed() {}
  void _viewPressed() {}

  void _reminderPressed(Reminder reminder) {}
}
