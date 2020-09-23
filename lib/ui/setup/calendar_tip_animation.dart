import 'package:flutter/material.dart';

/// Data describing the one-day event animation used in [CycleEditorScreen] and [WeeksEditorScreen].
class CalendarOneDayTipAnimation {
  static const clickTime = 0.2;
  static const waitTime = 0.7;

  // Variable naming convention: values corresponds to the timestamp where the specified action is completed.
  // For example, `releaseWaitTime` means the timestamp when the touch has released and waited.
  //
  // Timeline:
  //            @ clickTime          @ waitTime
  // hover ------- click ------------ hover -------
  static const hoverSize = 55.0;
  static const clickSize = 48.0;
  static const hoverOpacity = 0.5;
  static const clickOpacity = 0.85;
  static const hoverElevation = 20.0;

  final double size, opacity, elevation;

  const CalendarOneDayTipAnimation({
    this.size,
    this.opacity,
    this.elevation,
  });

  /// Create a [CalendarOneDayTipAnimation] from a time of the animation.
  ///
  /// [t] must be between 0 and 1 inclusive.
  factory CalendarOneDayTipAnimation.fromTime(double t) {
    assert(t >= 0 && t <= 1, 't must be between 0 and 1 inclusive.');
    if (t < clickTime) {
      t = t / clickTime;
      return CalendarOneDayTipAnimation(
        size:
            hoverSize - Curves.easeInOut.transform(t) * (hoverSize - clickSize),
        opacity: t * (clickOpacity - hoverOpacity) + (hoverOpacity),
        elevation: hoverElevation * (1 - t),
      );
    } else if (t < waitTime) {
      t = (t - clickTime) / (waitTime - clickTime);
      return CalendarOneDayTipAnimation(
        size:
            clickSize + (hoverSize - clickSize) * Curves.easeInOut.transform(t),
        opacity: clickOpacity - t * (clickOpacity - hoverOpacity),
        elevation: t * hoverElevation,
      );
    } else {
      return CalendarOneDayTipAnimation(
        size: hoverSize,
        opacity: hoverOpacity,
        elevation: hoverElevation,
      );
    }
  }
}

/// Data describing the multi-day event animation used in [CycleEditorScreen] and [WeeksEditorScreen].
class CalendarMultiDayTipAnimation {
  static const fadeInTime = 0.12;
  static const fadeInWaitTime = 0.21;
  static const pressTime = 0.24;
  static const holdTime = 0.42;
  static const moveTime = 0.6;
  static const moveWaitTime = 0.65;
  static const releaseTime = 0.69;
  static const releaseWaitTime = 0.79;
  static const fadeOutTime = 0.9;

  // Variable naming convention: values corresponds to the timestamp where the specified action is completed.
  // For example, `releaseWaitTime` means the timestamp when the touch has released and waited.
  //
  // Timeline: (@x represents the x-th timestamp because there is not enough space
  //        fade in   @1     wait    @2     press    @3       wait     @4         move            @5     wait    @6     release    @7       wait     @8   fade out   @9      wait
  // hidden -------- hover -------- hover -------- pressed ---------- held -------------------- moved --------- moved --------- released --------- hover --------- hidden ----------
  static const hoverSize = 55.0;
  static const clickSize = 48.0;
  static const hoverOpacity = 0.5;
  static const clickOpacity = 0.85;
  static const hoverElevation = 20.0;
  static const posBeginX = 0.2;
  static const posEndX = 0.8;
  static const posBeginY = 0.4;
  static const posEndY = 0.6;

  /// X-coordinate of the position.
  ///
  /// Proportional to the screen width.
  final double posX;

  /// Y-coordinate of the position.
  ///
  /// Proportional to the screen height.
  final double posY;
  final double opacity, elevation, size;

  const CalendarMultiDayTipAnimation({
    this.posX,
    this.posY,
    this.opacity,
    this.elevation,
    this.size,
  });

  /// Create a [CalendarMultiDayTipAnimation] from a time of the animation.
  ///
  /// [t] must be between 0 and 1 inclusive.
  factory CalendarMultiDayTipAnimation.fromTime(double t) {
    assert(t >= 0 && t <= 1, 't must be between 0 and 1 inclusive.');
    if (t < fadeInTime) {
      t = t / fadeInTime;
      return CalendarMultiDayTipAnimation(
        posX: posBeginX,
        posY: posBeginY,
        opacity: t * hoverOpacity,
        elevation: hoverElevation,
        size: hoverSize,
      );
    } else if (t < fadeInWaitTime) {
      return CalendarMultiDayTipAnimation(
        posX: posBeginX,
        posY: posBeginY,
        opacity: hoverOpacity,
        elevation: hoverElevation,
        size: hoverSize,
      );
    } else if (t < pressTime) {
      t = (t - fadeInWaitTime) / (pressTime - fadeInWaitTime);
      return CalendarMultiDayTipAnimation(
        posX: posBeginX,
        posY: posBeginY,
        size:
            hoverSize - Curves.easeInOut.transform(t) * (hoverSize - clickSize),
        opacity: t * (clickOpacity - hoverOpacity) + (hoverOpacity),
        elevation: hoverElevation * (1 - t),
      );
    } else if (t < holdTime) {
      return CalendarMultiDayTipAnimation(
        posX: posBeginX,
        posY: posBeginY,
        size: clickSize,
        opacity: clickOpacity,
        elevation: 0.0,
      );
    } else if (t < moveTime) {
      t = (t - holdTime) / (moveTime - holdTime);
      return CalendarMultiDayTipAnimation(
        posX: Curves.easeInOut.transform(t) * (posEndX - posBeginX) + posBeginX,
        posY: Curves.easeInOut.transform(t) * (posEndY - posBeginY) + posBeginY,
        opacity: clickOpacity,
        elevation: 0.0,
        size: clickSize,
      );
    } else if (t < moveWaitTime) {
      return CalendarMultiDayTipAnimation(
        posX: posEndX,
        posY: posEndY,
        opacity: clickOpacity,
        elevation: 0.0,
        size: clickSize,
      );
    } else if (t < releaseTime) {
      t = (t - moveWaitTime) / (releaseTime - moveWaitTime);
      return CalendarMultiDayTipAnimation(
        posX: posEndX,
        posY: posEndY,
        size:
            clickSize + (hoverSize - clickSize) * Curves.easeInOut.transform(t),
        opacity: clickOpacity - t * (clickOpacity - hoverOpacity),
        elevation: t * hoverElevation,
      );
    } else if (t < releaseWaitTime) {
      return CalendarMultiDayTipAnimation(
        posX: posEndX,
        posY: posEndY,
        size: hoverSize,
        opacity: hoverOpacity,
        elevation: hoverElevation,
      );
    } else if (t < fadeOutTime) {
      t = (t - releaseWaitTime) / (fadeOutTime - releaseWaitTime);
      return CalendarMultiDayTipAnimation(
        posX: posEndX,
        posY: posEndY,
        size: hoverSize,
        opacity: hoverOpacity * (1 - t),
        elevation: hoverElevation,
      );
    } else {
      return CalendarMultiDayTipAnimation(
        posX: posEndX,
        posY: posEndY,
        size: hoverSize,
        opacity: 0,
        elevation: hoverElevation,
      );
    }
  }
}
