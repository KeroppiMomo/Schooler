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
  String comment;

  Assignment({
    this.isCompleted = false,
    @required this.name,
    this.description,
    this.subject,
    this.dueDate,
    this.withDueTime,
    this.comment,
  });
}
