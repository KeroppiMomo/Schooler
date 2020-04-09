import 'package:quiver/core.dart';
import 'package:schooler/lib/settings.dart';
import 'package:schooler/lib/subject.dart';
import 'package:flutter/foundation.dart';

class Assignment {
  bool isCompleted;
  String name;
  String description;
  Subject subject;
  DateTime dueDate;

  /// Whether the assignment has a due time, not only a due date.
  bool withDueTime;
  String notes;

  Assignment({
    this.isCompleted = false,
    @required this.name,
    this.description,
    this.subject,
    this.dueDate,
    this.withDueTime,
    this.notes,
  });

  // Serilization -------------------------------------
  Map<String, Object> toJSON() {
    return {
      'completed': isCompleted,
      'name': name,
      'description': description,
      'subject': subject?.toJSON(),
      'due_epoch_ms': dueDate?.millisecondsSinceEpoch,
      'due_time': withDueTime,
      'notes': notes,
    };
  }

  static Assignment fromJSON(Map<String, Object> json) {
    if (json == null) return null;

    /// Convert a number of millisecond since epoch to DateTime.
    /// If `msSinceEpoch` is `null`, returns `null`.
    DateTime nullableUnixEpochToDateTime(int msSinceEpoch) =>
        msSinceEpoch == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);

    final isCompleted = json['completed'];
    final name = json['name'];
    final description = json['description'];
    final subject = json['subject'];
    final dueEpochMS = json['due_epoch_ms'];
    final withDueTime = json['due_time'];
    final notes = json['notes'];

    if ((isCompleted is bool || isCompleted == null) &&
        (name is String || name == null) &&
        (description is String || description == null) &&
        (subject is Map<String, Object> || subject == null) &&
        (dueEpochMS is int || dueEpochMS == null) &&
        (withDueTime is bool || withDueTime == null) &&
        (notes is String || notes == null)) {
      return Assignment(
        isCompleted: isCompleted ?? false,
        name: name ?? '',
        description: description,
        subject: Subject.fromJSON(subject),
        dueDate: nullableUnixEpochToDateTime(dueEpochMS),
        withDueTime: withDueTime,
        notes: notes,
      );
    } else {
      final curTypeMessage = [
        'completed',
        'name',
        'description',
        'subject',
        'due_epoch_ms',
        'due_time',
        'notes',
      ].map((key) => key + ': ' + json[key].runtimeType.toString()).join(', ');
      throw ParseJSONException(
          message:
              'Assignment type mismatch: $curTypeMessage found; bool, String, String, Map<String, Object>, int, bool, String expected');
    }
  }

  static List<Assignment> fromJSONList(dynamic json) {
    if (json == null) return null;
    final jsonList = () {
      try {
        final tmpList = json as List;
        return tmpList.cast<Map<String, Object>>();
      } catch (e) {
        throw ParseJSONException(
            message:
                'Assignment List type mismatch: ${json.runtimeType} found; List<Map<String, Object>> expected');
      }
    }();

    return jsonList.map((map) => Assignment.fromJSON(map)).toList();
  }

  // Identity -------------------------------------------------------
  bool operator ==(other) {
    return other is Assignment &&
        other.isCompleted == this.isCompleted &&
        other.name == this.name &&
        other.description == this.description &&
        other.subject == this.subject &&
        other.dueDate == this.dueDate &&
        other.withDueTime == this.withDueTime &&
        other.notes == this.notes;
  }

  int get hashCode => hashObjects(
      [isCompleted, name, description, subject, dueDate, withDueTime, notes]);
}
