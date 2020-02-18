import 'package:flutter/material.dart';

class Subject {
  String name;
  Color color;

  Subject(this.name, {this.color = Colors.grey}): assert(color != null);
}
