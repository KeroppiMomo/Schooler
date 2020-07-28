import 'package:flutter/material.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/main_tabs/wwidgets/wwidget.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:schooler/ui/subject_block.dart';
import 'package:schooler/ui/reminder_screen.dart';

final RemindersWWidgetReosurces _R = R.remindersWWidget;

class RemindersWWidget extends StatefulWidget {
  @override
  RemindersWWidgetState createState() => RemindersWWidgetState();
}

class RemindersWWidgetState extends State<RemindersWWidget> {
  @override
  Widget build(BuildContext context) {
    return WWidget(
      title: _R.wwidgetTitle,
      icon: _R.wwidgetIcon,
      contentPadding: _R.wwidgetPadding,
      onSettingsPressed: _settingsPressed,
      child: ValueListenableBuilder(
        valueListenable: Settings().reminderListener,
        builder: (context, _, __) => Column(
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
              label: Text(_R.getViewText(Settings().reminders.length)),
              onPressed: _viewPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminder(Reminder reminder) {
    final String triggerString = () {
      if (reminder.trigger == null) {
        return _R.reminderNoTriggerText;
      } else if (reminder.trigger is LocationReminderTrigger) {
        final trigger = reminder.trigger as LocationReminderTrigger;
        final region = trigger.region;

        if (region == null) return _R.locationReminderNullText;

        return _R.reminderGeofenceEventString[trigger.geofenceEvent] +
            trigger.region.location.getUserDescription(
                geocoderCompletion: (addresses) {
              setState(() {
                Settings().reminderListener.notifyListeners();
              });
            });
      } else if (reminder.trigger is TimeReminderTrigger) {
        final dateTime = (reminder.trigger as TimeReminderTrigger).dateTime;
        if (dateTime == null) return _R.timeReminderNullText;
        return _R.reminderDateFormat.format(dateTime);
      } else {
        assert(false, 'Unknown subtype of ReminderTrigger');
        return '';
      }
    }();

    final triggerIcon = _R.reminderTriggerIcon[reminder.trigger.runtimeType];

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
                    if (triggerIcon != null)
                      Icon(
                        triggerIcon,
                        color: _R.reminderTriggerIconColor,
                        size: _R.reminderTriggerIconSize,
                      ),
                    if (triggerIcon != null)
                      SizedBox(width: _R.reminderTriggerIconTextSpacing),
                    Expanded(
                      child: Text(
                        triggerString,
                        style: _R.reminderTriggerTextStyle(context),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  void _settingsPressed() {
    // TODO: Implement this
  }

  void _addPressed() {
    final reminder = Reminder(
      id: Reminder.generateID(),
      name: '',
      enabled: true,
      subject: null,
      trigger: null,
      notes: '',
    );
    Settings().reminders.add(reminder);
    Settings().reminderListener.notifyListeners();
    Settings().saveSettings();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ReminderScreen(reminder: reminder),
    ));
  }

  void _viewPressed() {
    // TODO: Implement this
  }

  void _reminderPressed(Reminder reminder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ReminderScreen(reminder: reminder),
    ));
  }
}
