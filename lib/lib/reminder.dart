import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoder/geocoder.dart';
import 'package:quiver/core.dart';
import 'package:schooler/lib/cycle_week_config.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:schooler/lib/geocoder_results.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/subject.dart';
import 'package:schooler/lib/timetable.dart';
import 'package:schooler/lib/geofencing.dart';
import 'package:workmanager/workmanager.dart';

abstract class ReminderTrigger {
  Future<void> register(
      {@required int id, @required bool enabled, @required String title});
  Future<void> unregister({int id});

  // Serilization
  String get jsonType;
  Map<String, Object> toJSON();
  static ReminderTrigger fromJSON(String type, Map<String, Object> json) {
    if (type == null)
      return null;
    else if (type == 'location')
      return LocationReminderTrigger.fromJSON(json);
    else if (type == 'time')
      return TimeReminderTrigger.fromJSON(json);
    else {
      assert(false, 'Unknown ReminderTrigger type string');
      return null;
    }
  }
}

// ---------------------------------------------------------------------------------

class LocationReminderLocation {
  double latitude;
  double longitude;

  LocationReminderLocation({
    @required this.latitude,
    @required this.longitude,
  });

  String getUserDescription({void Function(List<Address>) geocoderCompletion}) {
    String locationDescription = Settings().savedLocations[this];
    if (locationDescription == null) {
      if (geocoderResults[this] == null) {
        locationDescription = '($latitude, $longitude)';
        Geocoder.local
            .findAddressesFromCoordinates(Coordinates(latitude, longitude))
            .then((addresses) {
          geocoderResults[this] = addresses[0];
          geocoderCompletion(addresses);
        });
        geocoderResults[this] = Address();
      } else if (geocoderResults[this].featureName == null) {
        // An geocoding request has been made by others
        locationDescription = '($latitude, $longitude)';
      } else {
        locationDescription = '"' + geocoderResults[this].featureName + '"';
      }
    } else {
      locationDescription = '"' + locationDescription + '"';
    }

    return locationDescription;
  }

  // Serilization
  Map<String, Object> toJSON() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static LocationReminderLocation fromJSON(Map<String, Object> json) {
    if (json == null) return null;

    final lat = json['latitude'];
    final lng = json['longitude'];

    if (lat is num && lng is num) {
      return LocationReminderLocation(
        latitude: lat.toDouble(),
        longitude: lng.toDouble(),
      );
    } else {
      final curTypeMessage = [
        'latitude',
        'longitude',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'LocationReminderLocation type mismatch: $curTypeMessage found; non-null num, non-null num expected');
    }
  }

  static List<Map<String, Object>> savedLocationsToJSON(
      Map<LocationReminderLocation, String> savedLocations) {
    return savedLocations?.entries
        ?.map((entry) => {
              'location': entry.key.toJSON(),
              'name': entry.value,
            })
        ?.toList();
  }

  static Map<LocationReminderLocation, String> savedLocationsFromJSON(
      Object json) {
    if (json == null) return null;

    bool isStringObjectMapList(dynamic obj) {
      if (obj is! List) return false;
      try {
        obj.cast<Map<String, Object>>();
        return true;
      } catch (e) {
        return false;
      }
    }

    if (!isStringObjectMapList(json)) {
      throw ParseJSONException(
          message:
              'Saved locations type mismatch: ${json.runtimeType} found; List<Map<String, Object>> expected.');
    }

    final jsonList = (json as List).cast<Map<String, Object>>();

    final result = Map<LocationReminderLocation, String>();
    for (final map in jsonList) {
      final locationJSON = map['location'];
      final name = map['name'];

      if (name is! String) {
        throw ParseJSONException(
            message:
                'Saved locations type mismatch: name type ${json.runtimeType} found; String expected.');
      }

      result[LocationReminderLocation.fromJSON(locationJSON)] = name;
    }

    return result;
  }

  // Equality
  operator ==(other) =>
      other is LocationReminderLocation &&
      other.latitude == this.latitude &&
      other.longitude == this.longitude;

  int get hashCode => hashObjects([latitude, longitude]);
}

class LocationReminderRegion {
  LocationReminderLocation location;

  /// Radius of the region in meter.
  int radius;

  LocationReminderRegion({
    @required this.location,
    @required this.radius,
  });

  Map<String, Object> toJSON() {
    return {
      'radius': radius,
      'location': location.toJSON(),
    };
  }

  static LocationReminderRegion fromJSON(Map<String, Object> json) {
    final radius = json['radius'];
    final location = json['location'];

    if (radius is int && location is Map<String, Object>) {
      return LocationReminderRegion(
        radius: radius,
        location: LocationReminderLocation.fromJSON(location),
      );
    } else {
      final curTypeMessage = [
        'radius',
        'location',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'LocationReminderRegion type mismatch: $curTypeMessage found; non-null int, non-null Map<String, Object> expected');
    }
  }

  // Equality
  operator ==(other) =>
      other is LocationReminderRegion &&
      other.radius == this.radius &&
      other.location == this.location;

  int get hashCode => hashObjects([radius, location]);
}

class LocationReminderTrigger implements ReminderTrigger {
  LocationReminderRegion region;
  GeofenceEvent geofenceEvent;

  LocationReminderTrigger({
    this.region,
    @required this.geofenceEvent,
  });

  Future<void> register(
      {@required int id,
      @required bool enabled,
      @required String title}) async {
    await unregister(id: id);

    if (!enabled) return;
    if (region == null) return;

    await Geofencing.startMonitoring(
      id: id.toString(),
      title: title,
      geofenceEvent: geofenceEvent,
      region: region,
    );
  }

  Future<void> unregister({int id}) async {
    await Geofencing.stopMonitoring(id: id.toString());
  }

  // Serilization -------------------------------------
  String get jsonType => 'location';
  Map<String, Object> toJSON() {
    return {
      'geofence_event': geofenceEvent.index,
      'region': region?.toJSON(),
    };
  }

  static LocationReminderTrigger fromJSON(Map<String, Object> json) {
    final geofenceEvent = json['geofence_event'];
    final region = json['region'];

    if ((region is Map<String, Object> || region == null) &&
        geofenceEvent is int) {
      return LocationReminderTrigger(
        region: region == null ? null : LocationReminderRegion.fromJSON(region),
        geofenceEvent: GeofenceEvent.values[geofenceEvent],
      );
    } else {
      final curTypeMessage = [
        'geofence_event',
        'region',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'LocationReminderTrigger type mismatch: $curTypeMessage found; int, Map<String, Object> expected');
    }
  }

  // Equality
  operator ==(other) =>
      other is LocationReminderTrigger &&
      other.region == this.region &&
      other.geofenceEvent == this.geofenceEvent;

  int get hashCode => hashObjects([region, geofenceEvent]);
}

// ---------------------------------------------------------------------------------

class TimeReminderRepeat {
  /// Value of a repeat.
  final int _value;

  /// Data for TimeReminderRepeat.timetableDay and .weekDay.
  final Object _data;

  const TimeReminderRepeat._(this._value, this._data);

  static const day = TimeReminderRepeat._(0, null);
  static TimeReminderRepeat weekDay(int day) => TimeReminderRepeat._(1, day);
  static TimeReminderRepeat timetableDay(TimetableDay day) =>
      TimeReminderRepeat._(2, day);
  static const month = TimeReminderRepeat._(3, null);
  static const year = TimeReminderRepeat._(4, null);

  int getWeekDay() => _value == 1 ? (_data as int) : null;
  TimetableDay getTimetableDay() =>
      _value == 2 ? (_data as TimetableDay) : null;

  /// Returns whether a date matches the repeat with a specific start date.
  bool isDateMatched(DateTime date, DateTime oriDate,
      Map<DateTime, CalendarDayInfo> calendar) {
    date = removeTimeFrom(date);
    oriDate = removeTimeFrom(oriDate);
    switch (_value) {
      case 0:
        return true;
      case 1:
        return date.weekday == getWeekDay();
      case 2:
        final dayInfo = calendar[date];
        if (getTimetableDay() is TimetableWeekDay) {
          return date.weekday ==
              (getTimetableDay() as TimetableWeekDay).dayOfWeek;
        } else if (getTimetableDay() is TimetableCycleDay) {
          return dayInfo.cycleDay ==
              (getTimetableDay() as TimetableCycleDay).dayOfCycle.toString();
        } else if (getTimetableDay() is TimetableOccasionDay) {
          return [...(dayInfo.holidays ?? []), ...(dayInfo.occasions ?? [])]
              .any((event) =>
                  event.name ==
                  (getTimetableDay() as TimetableOccasionDay).occasionName);
        } else {
          assert(false, 'Unknown TimetableDay subtype');
        }
        return false;
      case 3:
        return date.day == oriDate.day;
      case 4:
        return date.month == oriDate.month && date.day == oriDate.day;
      default:
        assert(false, 'Unknown TimeReminderRepeat value');
        return false;
    }
  }

  // Serilization -------------------------------------
  Map<String, Object> toJSON() {
    return {
      'value': _value,
      'data': (() {
        if (_data == null)
          return null;
        else if (_data is int)
          return _data;
        else if (_data is TimetableDay) {
          return {
            'day_type': (_data as TimetableDay).jsonType(),
            'day_value': (_data as TimetableDay).jsonValue(),
          };
        } else {
          assert(false, 'Unknown TimeReminderRepeat._data type');
          return null;
        }
      })(),
    };
  }

  static TimeReminderRepeat fromJSON(Map<String, Object> json) {
    if (json == null) return null;
    final value = json['value'];
    final data = json['data'];

    if (value is int) {
      switch (value) {
        case 0:
          return TimeReminderRepeat.day;
        case 1:
          if (data is! int) {
            throw ParseJSONException(
                message:
                    'TimeReminderRepeat type mismatch: data is ${data.runtimeType}, should be int since value is 1');
          }
          return TimeReminderRepeat.weekDay(data);
        case 2:
          if (data is! Map<String, Object>) {
            throw ParseJSONException(
                message:
                    'TimeReminderRepeat type mismatch: data is ${data.runtimeType}, should be Map<String, Object> since value is 2');
          }
          final dayType = (data as Map<String, Object>)['day_type'];
          final dayValue = (data as Map<String, Object>)['day_value'];
          if (dayType is! String && dayType != null) {
            throw ParseJSONException(
                message:
                    'TimeReminderRepeat type mismatch: data["day_type"] is ${dayType.runtimeType}, should be String');
          }
          return TimeReminderRepeat.timetableDay(
              TimetableDay.fromJSON(dayType, dayValue));
        case 3:
          return TimeReminderRepeat.month;
        case 4:
          return TimeReminderRepeat.year;
        default:
          assert(false, 'Unknown TimeReminderRepeat _value');
          return null;
      }
    } else {
      throw ParseJSONException(
          message:
              'TimeReminderRepeat type mismatch: value is ${value.runtimeType}, should be int');
    }
  }

  // Equality ---------------------------
  bool operator ==(other) =>
      other is TimeReminderRepeat &&
      other._value == this._value &&
      other._data == this._data;
  int get hashCode => hash2(_value, _data);
}

class TimeReminderTrigger implements ReminderTrigger {
  DateTime dateTime;
  TimeReminderRepeat repeat;

  TimeReminderTrigger({
    @required this.dateTime,
    this.repeat,
  });

  Future<void> register(
      {@required int id,
      @required bool enabled,
      @required String title}) async {
    TimeReminderCenter().registerAll();
  }

  Future<void> unregister({@required int id}) async {
    // Remove scheduled notifications of this reminder
    for (int i = 0; i < 64; i++) {
      FlutterLocalNotificationsPlugin().cancel(id % (1 << 16) * 64 + i);
    }
  }

  // Serilization
  String get jsonType => 'time';
  Map<String, Object> toJSON() {
    return {
      'date_time': dateTime.millisecondsSinceEpoch,
      'repeat': repeat?.toJSON(),
    };
  }

  static TimeReminderTrigger fromJSON(Map<String, Object> json) {
    if (json == null) return null;
    final dateTimeMS = json['date_time'];
    final repeat = json['repeat'];

    if ((dateTimeMS is int) &&
        (repeat is Map<String, Object> || repeat == null)) {
      return TimeReminderTrigger(
        dateTime: DateTime.fromMillisecondsSinceEpoch(dateTimeMS),
        repeat: TimeReminderRepeat.fromJSON(repeat),
      );
    } else {
      final curTypeMessage = [
        'date_time',
        'repeat',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'TimeReminderTrigger type mismatch: $curTypeMessage found; non-null int, Map<String, Object> expected');
    }
  }

  // Equality
  bool operator ==(o) =>
      o is TimeReminderTrigger &&
      o.dateTime == this.dateTime &&
      o.repeat == this.repeat;
  int get hashCode => hashObjects([dateTime, repeat]);
}

// ---------------------------------------------------------------------------------

class Reminder {
  int id;
  String name;
  bool enabled;
  Subject subject;
  ReminderTrigger trigger;
  String notes;

  Reminder({
    @required this.id,
    @required this.name,
    this.enabled = true,
    this.subject,
    this.trigger,
    this.notes,
  });

  static int generateID() => Uuid().v1().hashCode;

  Future<void> register() async {
    final notificationTitle =
        (subject == null ? '' : '[${subject.name}] ') + name;
    await trigger?.register(id: id, enabled: enabled, title: notificationTitle);
  }

  Future<void> unregister() async {
    await trigger?.unregister(id: id);
  }

  // Serilization
  Map<String, Object> toJSON() {
    return {
      'id': id,
      'name': name,
      'enabled': enabled,
      'subject': subject?.toJSON(),
      'trigger_type': trigger?.jsonType,
      'trigger': trigger?.toJSON(),
      'notes': notes,
    };
  }

  static Reminder fromJSON(Map<String, Object> json) {
    if (json == null) return null;

    final id = json['id'];
    final name = json['name'];
    final enabled = json['enabled'];
    final subject = json['subject'];
    final triggerType = json['trigger_type'];
    final trigger = json['trigger'];
    final notes = json['notes'];

    if ((id is int) &&
        (name is String) &&
        (enabled is bool) &&
        (subject is Map<String, Object> || subject == null) &&
        (triggerType is String || triggerType == null) &&
        (trigger is Map<String, Object> || trigger == null) &&
        (notes is String || notes == null)) {
      return Reminder(
        id: id,
        name: name,
        enabled: enabled,
        subject: subject == null ? null : Subject.fromJSON(subject),
        trigger: ReminderTrigger.fromJSON(triggerType, trigger),
        notes: notes,
      );
    } else {
      final curTypeMessage = [
        'id',
        'name',
        'enabled',
        'subject',
        'trigger_type',
        'trigger',
        'notes',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'Reminder type mismatch: $curTypeMessage found; non-null int, non-null String, non-null bool, Map<String, Object>, String, Map<String, Object>, String expected');
    }
  }

  static List<Reminder> fromJSONList(dynamic json) {
    if (json == null) return null;
    final jsonList = () {
      try {
        final tmpList = json as List;
        return tmpList.cast<Map<String, Object>>();
      } catch (e) {
        throw ParseJSONException(
            message:
                'Reminder List type mismatch: ${json.runtimeType} found; List<Map<String, Object>> expected');
      }
    }();

    return jsonList.map((map) => Reminder.fromJSON(map)).toList();
  }

  // Equality
  bool operator ==(o) =>
      o is Reminder &&
      o.id == this.id &&
      o.name == this.name &&
      o.enabled == this.enabled &&
      o.subject == this.subject &&
      o.trigger == this.trigger &&
      o.notes == this.notes;

  int get hashCode => hashObjects([id, name, enabled, subject, trigger, notes]);
}

class _TimeReminderCenterScheduleInfo {
  final DateTime dateTime;
  final String title;
  final int id;

  const _TimeReminderCenterScheduleInfo({
    this.dateTime,
    this.title,
    this.id,
  });
}

class TimeReminderCenter {
  static TimeReminderCenter instance = TimeReminderCenter._();
  TimeReminderCenter._();
  factory TimeReminderCenter() => TimeReminderCenter.instance;

  /// Register all time-based reminders. Set [editOldDates] to true to
  /// edit reminder dates that are older than now to its next trigger date.
  Future<void> registerAll({bool editOldDates = false}) async {
    await unregisterAll();

    final Map<DateTime, CalendarDayInfo> calendar = () {
      if (Settings().calendarType == CalendarType.week)
        return Settings().weekConfig.getCalendar();
      else if (Settings().calendarType == CalendarType.cycle)
        return Settings().cycleConfig.getCalendar();
      else {
        return null;
      }
    }();

    if (calendar == null) return;

    final scheduleInfos = <_TimeReminderCenterScheduleInfo>[];
    for (final reminder in Settings().reminders) {
      if (reminder.trigger is! TimeReminderTrigger) continue;
      if (!reminder.enabled) continue;

      final trigger = reminder.trigger as TimeReminderTrigger;
      int idCount = 0;

      /// Original DateTime of the trigger.
      final oriDateTime = (reminder.trigger as TimeReminderTrigger).dateTime;

      /// Current date for checking the matched dates.
      DateTime curDate;

      /// First matched date for editing old dates.
      DateTime firstMatchedDate;
      if (oriDateTime.isAfter(DateTime.now())) {
        scheduleInfos.add(_TimeReminderCenterScheduleInfo(
          id: reminder.id % (1 << 16) * 64,
          dateTime: oriDateTime,
          title: reminder.name,
        ));
        idCount++;
        curDate = removeTimeFrom(oriDateTime).add(Duration(days: 1));
        firstMatchedDate = oriDateTime;
      } else {
        curDate = removeTimeFrom(DateTime.now());
      }

      /// Should the date be edited?
      final shouldEditDate =
          (editOldDates && !oriDateTime.isAfter(DateTime.now()));

      if (trigger.repeat == null) {
        if (shouldEditDate) {
          // Similar to reminders that cannot find its next matched dates, no repeat reminders
          // have no next dates, so it is set to be disabled.
          reminder.enabled = false;
        }
        continue;
      }

      // Restrict mix 64 notifications per reminder and only schedule notifications within one month (30 days)
      while (
          idCount < 64 && curDate.difference(trigger.dateTime).inDays <= 30) {
        if (trigger.repeat.isDateMatched(curDate, trigger.dateTime, calendar)) {
          final date = DateTime(curDate.year, curDate.month, curDate.day,
              oriDateTime.hour, oriDateTime.minute, oriDateTime.second);

          if (!date.isAfter(DateTime.now())) {
            curDate = curDate.add(Duration(days: 1));
            continue;
          }

          if (firstMatchedDate == null) firstMatchedDate = date;

          scheduleInfos.add(_TimeReminderCenterScheduleInfo(
            id: (reminder.id % (1 << 16) * 64) + idCount,
            dateTime: date,
            title: reminder.name,
          ));
          idCount++;
        }
        curDate = curDate.add(Duration(days: 1));
      }

      if (shouldEditDate) {
        // Find the first matched date for editing old dates. Assume there are no more matched dates after one year (370 days)
        while (shouldEditDate &&
            firstMatchedDate == null &&
            curDate.difference(trigger.dateTime).inDays <= 370) {
          if (trigger.repeat
              .isDateMatched(curDate, trigger.dateTime, calendar)) {
            firstMatchedDate = curDate;
            break;
          }
          curDate = curDate.add(Duration(days: 1));
        }

        if (firstMatchedDate == null) {
          // Similar to no repeat reminders, the reminder are disabled if we can't find the next matched date
          reminder.enabled = false;
        } else {
          // Set the dateTime to the first matched date.
          trigger.dateTime = DateTime(
              firstMatchedDate.year,
              firstMatchedDate.month,
              firstMatchedDate.day,
              oriDateTime.hour,
              oriDateTime.minute,
              oriDateTime.second);
        }
      }
    }

    scheduleInfos.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final maxNotificationCount = () {
      if (Platform.isIOS)
        return 64;
      else if (Platform.isAndroid)
        return 50;
      else {
        assert(false,
            "Unknown platform. Future me must have to much time to implement this.");
        return 64;
      }
    }();
    final takenSchedules = scheduleInfos.take(maxNotificationCount);

    final futures = <Future>[];
    for (final scheduleInfo in takenSchedules) {
      futures.add(FlutterLocalNotificationsPlugin().schedule(
        scheduleInfo.id,
        scheduleInfo.title,
        'Schooler Reminder',
        scheduleInfo.dateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Reminders',
            null,
            priority: Priority.high,
            importance: Importance.high,
            visibility: NotificationVisibility.private,
            category: 'reminder',
          ),
          iOS: IOSNotificationDetails(),
        ),
      ));
    }

    await Future.wait(futures);
  }

  Future<void> unregisterAll() async {
    for (final reminder in Settings().reminders) {
      if (reminder.trigger is TimeReminderTrigger) {
        await reminder.unregister();
      }
    }
  }
}

void initializeLocalNotifications() {
  final androidSettings = AndroidInitializationSettings('notification_icon');
  final iOSSettings = IOSInitializationSettings();
  FlutterLocalNotificationsPlugin().initialize(InitializationSettings(
    android: androidSettings,
    iOS: iOSSettings,
  ));
}

void reminderBackgroundCallback() {
  Workmanager.executeTask((_, __) => reminderBackgroundRegister());
}

Future<bool> reminderBackgroundRegister() async {
  await Settings.loadSettings();
  await TimeReminderCenter().registerAll(editOldDates: true);
  await Settings().saveSettings();

  return true;
}
