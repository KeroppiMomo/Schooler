import 'package:flutter/material.dart';
import 'package:quiver/core.dart';
import 'package:schooler/lib/settings.dart' show ParseJSONException;

class Subject {
  String name;
  Color color;

  Subject(this.name, {this.color = Colors.grey})
      : assert(name != null),
        assert(color != null);

  // Serilization -----------------------------------------
  Map<String, Object> toJSON() {
    return {
      'name': name,
      'color': color
          .value, // Color.value is a 32 bit (4 bytes) value. [ byte3, byte2, byte1, byte0 ] <=> [ A, R, G, B ]
    };
  }

  static Subject fromJSON(Map<String, Object> json) {
    if (json == null) return null;

    final name = json['name'];
    final colorValue = json['color'];

    // These two must not be null, so null check is not performed.
    if (name is String && colorValue is int) {
      return Subject(name, color: Color(colorValue));
    } else {
      final curTypeMessage = [
        'name',
        'color',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'Subject type mismatch: $curTypeMessage found; non-null String, non-null int expected');
    }
  }

  /// Convert a potential `List<Map<String, Object>>` JSON object into a `List` of `Subject`.
  /// Throw [ParseJSONException] when `json` is not a `List<Map<String, Object>>`.
  static List<Subject> fromJSONList(dynamic json) {
    if (json == null) return null;
    final jsonList = () {
      try {
        final tmpList = json as List;
        return tmpList.cast<Map<String, Object>>();
      } catch (e) {
        throw ParseJSONException(
            message:
                'Subject List type mismatch: ${json.runtimeType} found; List<Map<String, Object>> expected');
      }
    }();

    return jsonList.map((map) => Subject.fromJSON(map)).toList();
  }

  // Equality -------------------------------------------------
  bool operator ==(o) =>
      o is Subject && o.name == this.name && o.color == this.color;
  int get hashCode => hash2(name, color);
}
