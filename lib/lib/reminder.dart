import 'package:geocoder/geocoder.dart';
import 'package:quiver/core.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:schooler/lib/geocoder_results.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/subject.dart';
import 'package:geofencing/geofencing.dart';
import 'package:schooler/lib/timetable.dart';

abstract class ReminderTrigger {
  String id;
  void register(String title, String description);

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
  String id;
  LocationReminderRegion region;
  GeofenceEvent geofenceEvent;

  LocationReminderTrigger({
    this.id,
    this.region,
    @required this.geofenceEvent,
  });
  void register(String title, String description) {}

  // Serilization -------------------------------------
  String get jsonType => 'location';
  Map<String, Object> toJSON() {
    return {
      'id': id,
      'geofence_event': geofenceEvent.index,
      'region': region?.toJSON(),
    };
  }

  static LocationReminderTrigger fromJSON(Map<String, Object> json) {
    final id = json['id'];
    final geofenceEvent = json['geofence_event'];
    final region = json['region'];

    if ((id is String || id == null) &&
        (region is Map<String, Object> || region == null) &&
        geofenceEvent is int) {
      return LocationReminderTrigger(
        id: id,
        region: region == null ? null : LocationReminderRegion.fromJSON(region),
        geofenceEvent: GeofenceEvent.values[geofenceEvent],
      );
    } else {
      final curTypeMessage = [
        'id',
        'geofence_event',
        'region',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'LocationReminderTrigger type mismatch: $curTypeMessage found; String, int, Map<String, Object> expected');
    }
  }

  // Equality
  operator ==(other) =>
      other is LocationReminderTrigger &&
      other.id == this.id &&
      other.region == this.region &&
      other.geofenceEvent == this.geofenceEvent;

  int get hashCode => hashObjects([id, region, geofenceEvent]);
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
  String id;
  DateTime dateTime;
  TimeReminderRepeat repeat;

  TimeReminderTrigger({
    this.id,
    @required this.dateTime,
    this.repeat,
  });
  void register(String title, String description) {}

  // Serilization
  String get jsonType => 'time';
  Map<String, Object> toJSON() {
    return {
      'id': id,
      'date_time': dateTime.millisecondsSinceEpoch,
      'repeat': repeat?.toJSON(),
    };
  }

  static TimeReminderTrigger fromJSON(Map<String, Object> json) {
    if (json == null) return null;
    final id = json['id'];
    final dateTimeMS = json['date_time'];
    final repeat = json['repeat'];

    if ((id is String || id == null) &&
        (dateTimeMS is int) &&
        (repeat is Map<String, Object> || repeat == null)) {
      return TimeReminderTrigger(
        id: id,
        dateTime: DateTime.fromMillisecondsSinceEpoch(dateTimeMS),
        repeat: TimeReminderRepeat.fromJSON(repeat),
      );
    } else {
      final curTypeMessage = [
        'id',
        'date_time',
        'repeat',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'TimeReminderTrigger type mismatch: $curTypeMessage found; String, non-null int, Map<String, Object> expected');
    }
  }

  // Equality
  bool operator ==(o) =>
      o is TimeReminderTrigger &&
      o.id == this.id &&
      o.dateTime == this.dateTime &&
      o.repeat == this.repeat;
  int get hashCode => hashObjects([id, dateTime, repeat]);
}

// ---------------------------------------------------------------------------------

class Reminder {
  String id;
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

  static String generateID() => Uuid().v1();

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

    if ((id is String) &&
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
              'TimeReminderTrigger type mismatch: $curTypeMessage found; non-null String, non-null String, non-null bool, Map<String, Object>, String, Map<String, Object>, String expected');
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
