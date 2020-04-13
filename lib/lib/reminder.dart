import 'package:flutter/material.dart';
import 'package:schooler/lib/subject.dart';
import 'package:geofencing/geofencing.dart';
import 'package:schooler/lib/timetable.dart';

abstract class ReminderTrigger {
  void register(String id, String title, String description);
}

// ---------------------------------------------------------------------------------

class LocationReminderRegion {
  String name;
  double latitude;
  double longitude;

  /// Radius of the region in meter.
  int radius;

  LocationReminderRegion({
    this.name,
    this.latitude,
    this.longitude,
    this.radius,
  });
}

class LocationReminderTrigger implements ReminderTrigger {
  LocationReminderRegion region;
  GeofenceEvent geofenceEvent;
  bool triggerOnce;

  LocationReminderTrigger({
    @required this.region,
    @required this.geofenceEvent,
    this.triggerOnce = false,
  });
  void register(String id, String title, String description) {}
}

// ---------------------------------------------------------------------------------

class TimeReminderRepeat {
  /// Value of a repeat.
  final int _value;

  /// Data for TimeReminderRepeat.timetableDay and .weekDay.
  final Object _data;

  const TimeReminderRepeat._(this._value, this._data);

  static const day = TimeReminderRepeat._(0, null);
  TimeReminderRepeat weekDay(int day) => TimeReminderRepeat._(1, day);
  TimeReminderRepeat timetableDay(TimetableDay day) =>
      TimeReminderRepeat._(2, day);
  static const month = TimeReminderRepeat._(3, null);
  static const year = TimeReminderRepeat._(4, null);

  int get getWeekDay => _value == 1 ? (_data as int) : null;
  TimetableDay get getTimetableDay =>
      _value == 2 ? (_data as TimetableDay) : null;
}

class TimeReminderTrigger implements ReminderTrigger {
  DateTime dateTime;
  TimeReminderRepeat repeat;

  TimeReminderTrigger({this.dateTime});
  void register(String id, String title, String description) {}
}

// ---------------------------------------------------------------------------------

class Reminder {
  String id;
  String name;
  bool enabled;
  Subject subject;
  ReminderTrigger trigger;

  Reminder({
    @required this.id,
    @required this.name,
    this.enabled = true,
    this.subject,
    this.trigger,
  });
}
