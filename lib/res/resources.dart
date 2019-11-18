import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final R = Resources();
class Resources {
  final cyclesEditor = CyclesEditorResources();
  final editText = EditTextResources();
}

class CyclesEditorResources {
  final dateFormat = DateFormat('dd MMMM yyyy');
  final outsideMonthColor = Color(0x44000000);
}

class EditTextResources {
  
}