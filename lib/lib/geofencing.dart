import 'package:flutter/services.dart';
import 'package:schooler/lib/reminder.dart';
import 'package:meta/meta.dart';

/// The event to trigger a geofence.
enum GeofenceEvent { enter, exit }

abstract class GeofenceException implements Exception {
  final String code = '';
  final String message;
  GeofenceException([this.message]);

  @override
  String toString() => '$code: $message';
}

class GeofenceBadArgumentException implements GeofenceException {
  final String code = 'BAD_ARGUMENT';
  final String message;
  GeofenceBadArgumentException([this.message]);
}

class GeofenceUnavailableException implements GeofenceException {
  final String code = 'UNAVAILABLE';
  final String message;
  GeofenceUnavailableException([this.message]);
}

class GeofencePermissionDeniedException implements GeofenceException {
  final String code = 'PERMISSION_DENIED';
  final String message;
  GeofencePermissionDeniedException([this.message]);
}

class GeofenceMaximumGeofencesReachedException implements GeofenceException {
  final String code = 'MAX_GEOFENCES_REACHED';
  final String message;
  GeofenceMaximumGeofencesReachedException([this.message]);
}

class GeofenceMaximumRadiusReachedException implements GeofenceException {
  final String code = 'MAX_RADIUS_REACHED';
  final String message;
  GeofenceMaximumRadiusReachedException([this.message]);
}

class GeofenceUnknownException implements GeofenceException {
  final String code = 'UNKNOWN';
  final String message;
  GeofenceUnknownException([this.message]);
}

class Geofencing {
  static const _channel =
      const MethodChannel('com.example.schooler/geofencing');

  /// Convert a raw [PlatformException] into a subtype of [GeofenceException].
  static _resolvePlatformException(PlatformException exception) {
    switch (exception.code) {
      case 'BAD_ARGUMENT':
        return GeofenceBadArgumentException(exception.message);
      case 'UNAVAILABLE':
        return GeofenceUnavailableException(exception.message);
      case 'PERMISSION_DENIED':
        return GeofencePermissionDeniedException(exception.message);
      case 'MAX_GEOFENCES_REACHED':
        return GeofenceMaximumGeofencesReachedException(exception.message);
      case 'MAX_RADIUS_REACHED':
        return GeofenceMaximumRadiusReachedException(exception.message);
      default:
        return GeofenceUnknownException(exception.message);
    }
  }

  /// Request location permission.
  ///
  /// VERY IMPORTANT NOTE: iOS does not provide callback for permission prompts.
  /// - Android: returns whether "Always" location permission is granted after prompts.
  /// - iOS: returns whether "Always" location permission is granted BEFORE prompts.
  ///   Use `iOSAlwaysPermissionCallback` to listen for "Always" location permission being granted.
  static Future<bool> requestPermission(
      {@required void Function() iOSAlwaysPermissionCallback}) async {
    final bool result = await _channel.invokeMethod('requestPermission');
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'iOSAlwaysPermissionGranted') {
        iOSAlwaysPermissionCallback();
      }
    });
    return result;
  }

  /// Open the system Settings page of this app.
  ///
  /// Throws [GeofenceUnavailableException] if the action has failed.
  static Future<void> openAppsSettings() async {
    try {
      await _channel.invokeMethod('openAppsSettings');
    } on PlatformException catch (exception) {
      throw _resolvePlatformException(exception);
    }
  }

  /// Get the maximum radius of a geofence on the device.
  static Future<double> getMaximumRadius() async {
    try {
      return await _channel.invokeMethod('getMaximumRadius');
    } on PlatformException catch (exception) {
      throw _resolvePlatformException(exception);
    }
  }

  /// Start geofence monitoring and send a notification when it is triggered.
  ///
  /// Throws [GeofenceUnavailableException] if geofencing is unavailable on the device.
  /// Throws [GeofenceMaximumRadiusReachedException] if the radius of the geofence is
  /// larger than [Geofencing.getMaximumRadius()].
  /// Throws [GeofenceMaximumGeofencesReachedException] if there are too many
  /// geofences already registered.
  /// Throws [GeofencePermissionDeniedException] if the location permission is denied
  /// by the user. Note that this exception is not always thrown.
  /// Throws [GeofenceUnknownException] if an unknown error has occurred.
  static Future<void> startMonitoring({
    @required String id,
    @required String title,
    @required GeofenceEvent geofenceEvent,
    @required LocationReminderRegion region,
  }) async {
    try {
      await _channel.invokeMethod('startMonitoring', {
        'id': id,
        'title': title,
        'geofenceEvent': geofenceEvent.index,
        'latitude': region.location.latitude,
        'longitude': region.location.longitude,
        'radius': region.radius,
      });
    } on PlatformException catch (exception) {
      throw _resolvePlatformException(exception);
    }
  }

  /// Stop geofence monitoring.
  ///
  /// Throws [GeofenceUnavailableException] if geofencing is unavailable on the device.
  /// Throws [GeofenceUnknownException] if an unknown error has occurred.
  static Future<void> stopMonitoring({@required String id}) async {
    try {
      await _channel.invokeMethod('stopMonitoring', id);
    } on PlatformException catch (exception) {
      throw _resolvePlatformException(exception);
    }
  }
}
