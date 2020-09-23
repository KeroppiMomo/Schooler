import 'package:flutter/foundation.dart';

/// A [ValueNotifier] but expose [notifyListeners] to the public.
class ExternalValueNotifier<T> extends ValueNotifier<T> {
  ExternalValueNotifier(T value) : super(value);

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
