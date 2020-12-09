import 'package:flutter/material.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/res/resources.dart';
import 'package:schooler/ui/reminder_screen.dart';
import 'package:schooler/ui/list_screen.dart';
import 'package:schooler/ui/subject_block.dart';

RemindersListScreenResources _R = R.remindersListScreen;

class RemindersListScreen extends StatefulWidget {
  @override
  RemindersListScreenState createState() => RemindersListScreenState();
}

@visibleForTesting
class RemindersListScreenState extends State<RemindersListScreen> {
  @override
  Widget build(BuildContext context) {
    return ListScreen<Reminder>(
      appBarTitle: _R.appBarTitle,
      appBarActions: null,
      addFABTooltip: _R.addFABTooltip,
      addFABIcon: _R.addFABIcon,
      source: () => Settings().reminders,
      sortings: _R.reminderSorts,
      defaultSorting: _R.defaultSorting,
      defaultSortDirection: _R.defaultSortDirection,
      noSortText: _R.noSortText,
      searchString: _getSearchString,
      listener: Settings().reminderListener,
      separatorBuilder: (context, i) =>
          Divider(indent: _R.reminderIconColumnWidth),
      itemBuilder: (_, reminder) => _buildReminder(reminder),
      addPressed: _addPressed,
      itemPressed: _reminderPressed,
    );
  }

  String _getSearchString(Reminder reminder) {
    String str = "";
    str += reminder.name ?? '';
    str += '\n';
    str += reminder.notes ?? '';
    str += '\n';
    if (reminder.trigger is TimeReminderTrigger) {
      str += 'Time-based Trigger';
      str += '\n';
      if ((reminder.trigger as TimeReminderTrigger).dateTime != null) {
        str += _R.searchDateTimeFormat.format((reminder.trigger as TimeReminderTrigger).dateTime);
        str += '\n';
      }
      // Maybe add repeat later?
    } else if (reminder.trigger is LocationReminderTrigger) {
      str += 'Location-based Trigger';
      str += '\n';
      if ((reminder.trigger as LocationReminderTrigger).geofenceEvent != null) {
        str += _R.reminderGeofenceEventString[(reminder.trigger as LocationReminderTrigger).geofenceEvent];
        str += '\n';
        str += (reminder.trigger as LocationReminderTrigger).region.location.getUserDescription();
        str += '\n';
      }
    }

    return str;
  }

  Widget _buildReminder(Reminder reminder) {
    // Copied from `RemindersWWidgetState._buildReminder`
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

    return Padding(
      padding: _R.reminderPadding,
      child: Opacity(
        opacity: reminder.enabled ? 1.0 : _R.reminderDisabledOpacity,
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
    );
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

  void _reminderPressed(Reminder reminder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ReminderScreen(reminder: reminder),
    ));
  }
}
