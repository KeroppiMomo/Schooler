import Flutter
import CoreLocation
import UserNotifications

/// Wrapper on `FlutterError` which conforms to `Error` so it can be thrown.
class FlutterErrorError: FlutterError, Error {
    static func badArgument(_ message: String) -> FlutterErrorError {
        return self.init(code: "BAD_ARGUMENT", message: message, details: nil)
    }
    static func badArgument(_ expectedType: Any) -> FlutterErrorError {
        return badArgument("Argument is expected to be '\(expectedType)'")
    }
    static func badArgument(_ name: String, _ expectedType: Any) -> FlutterErrorError {
        return badArgument("'\(name)' is expected to be '\(expectedType)'")
    }

    static func unavailable(_ message: String) -> FlutterErrorError {
        return self.init(code: "UNAVAILABLE", message: message, details: nil)
    }
    static func permissionDenied(_ message: String) -> FlutterErrorError {
        return self.init(code: "PERMISSION_DENIED", message: message, details: nil)
    }
    static func maximumGeofencesReached(_ message: String) -> FlutterErrorError {
        return self.init(code: "MAX_GEOFENCES_REACHED", message: message, details: nil)
    }
    static func maximumRadiusReached(_ message: String) -> FlutterErrorError {
        return self.init(code: "MAX_RADIUS_REACHED", message: message, details: nil)
    }
    static func unknown(_ message: String) -> FlutterErrorError {
        return self.init(code: "UNKNOWN", message: message, details: nil)
    }
}

class Geofencing: NSObject, CLLocationManagerDelegate {
    enum GeofenceEvent {
        case enter
        case exit

        static func fromInt(_ value: Int) -> GeofenceEvent {
            assert(value == 0 || value == 1)
            if value == 0 { return .enter }
            else { return .exit }
        }
    }

    static let instance = Geofencing()
    private override init() {}

    /// A location manager for the plugin.
    private let locationManager = CLLocationManager()
    /// Used for `requestPermission` function to wait for permission change to return.
    private var requestPermissionCallback: ((CLAuthorizationStatus) -> Void)?
    /// Used for `startMonitoring` function to wait for completion.
    private var startMonitoringCallback: ((FlutterErrorError?) -> Void)?
    /// Method channel with Dart code.
    private var channel: FlutterMethodChannel!

    func initialize(controller: FlutterViewController) {
        channel = FlutterMethodChannel(name: "com.example.schooler/geofencing", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler(handleMethodCall)

        locationManager.delegate = self
    }

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        func handleError(error: Error) {
            if error is FlutterError {
                result(error)
            } else {
                result(FlutterError(code: String(describing: type(of: error)), message: error.localizedDescription, details: nil))
            }
        }
        do {
            switch (call.method) {
            case "requestPermission":
                requestPermission { result($0) }
            case "openAppsSettings":
                try openAppsSettings() {
                    result(nil)
                }
            case "getMaximumRadius":
                result(getMaximumRadius())
            case "startMonitoring":
                try startMonitoring(call.arguments) { error in
                    if let error = error { handleError(error: error) }
                    else { result(nil) }
                }
            case "stopMonitoring":
                try stopMonitoring(call.arguments)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        } catch let error as FlutterError {
            result(error)
        } catch {
            result(FlutterError(code: String(describing: type(of: error)), message: error.localizedDescription, details: nil))
        }
    }

    // MARK: Exposed methods
    /// Request location permission.
    ///
    /// - Important
    /// `CLLocationManager` provides no callback to when requesting Always permission after When In Use permission.
    /// When Always permission is granted, method `iOSAlwaysPermissionGranted` method is invoked through
    /// the method channel..
    private func requestPermission(completion: @escaping ((Bool) -> Void)) {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            completion(false)
        } else if status == .notDetermined {
            // First request When In Use permission, then Always permission
            requestPermissionCallback = { status in
                if status == .authorizedWhenInUse {
                    self.requestPermissionCallback = { status in
                        self.requestPermissionCallback = nil
                        if status == .authorizedAlways {
                            self.channel.invokeMethod("iOSAlwaysPermissionGranted", arguments: nil)
                        }
                    }
                    self.locationManager.requestAlwaysAuthorization()
                } else {
                    self.requestPermissionCallback = nil
                }
                // See `requestPermission` documentation
                completion(false)
            }
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            requestPermissionCallback = { status in
                self.requestPermissionCallback = nil
                if status == .authorizedAlways {
                    self.channel.invokeMethod("iOSAlwaysPermissionGranted", arguments: nil)
                }
            }
            completion(false)
            // See `requestPermission` documentation
        } else if status == .authorizedAlways {
            completion(true)
        } else {
            completion(false)
        }
    }
    private func openAppsSettings(completion: @escaping () -> Void) throws {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { throw FlutterErrorError.unavailable("Failed to create an URL from UIApplication.openSettingsURLString") }
        guard UIApplication.shared.canOpenURL(url) else { throw FlutterErrorError.unavailable("Failed to open URL") }
        UIApplication.shared.open(url, options: [:]) { _ in completion() }
    }
    private func getMaximumRadius() -> Double {
        return locationManager.maximumRegionMonitoringDistance
    }
    private func startMonitoring(_ arguments: Any?, completion: @escaping ((FlutterErrorError?) -> Void)) throws {
        guard let argDict = arguments as? Dictionary<String, Any>       else { throw FlutterErrorError.badArgument(Dictionary<String, Any>.self) }
        guard let id = argDict["id"] as? String                         else { throw FlutterErrorError.badArgument("id", String.self) }
        guard let title = argDict["title"] as? String                   else { throw FlutterErrorError.badArgument("title", String.self) }
        guard let geofenceEventInt = argDict["geofenceEvent"] as? Int   else { throw FlutterErrorError.badArgument("geofenceEvent", Int.self) }
        let geofenceEvent = GeofenceEvent.fromInt(geofenceEventInt)
        guard let latitude = argDict["latitude"] as? Double             else { throw FlutterErrorError.badArgument("latitude", Double.self) }
        guard let longitude = argDict["longitude"] as? Double           else { throw FlutterErrorError.badArgument("longitude", Double.self) }
        guard let radius = argDict["radius"] as? Int                    else { throw FlutterErrorError.badArgument("radius", Int.self) }


        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            throw FlutterErrorError.unavailable("Geofence monitoring is unavailable on this device.")
        }
        guard Double(radius) <= getMaximumRadius() else {
            throw FlutterErrorError.maximumRadiusReached("Radius is larger than \(getMaximumRadius()) meters.")
        }
        
        startMonitoringCallback = { error in
            self.startMonitoringCallback = nil
            completion(error)
        }

        locationManager.startMonitoring(for: region(forID: id, lat: latitude, lng: longitude, radius: radius, geofenceEvent: geofenceEvent))

        setGeofenceName(title, id: id)
    }
    private func stopMonitoring(_ arguments: Any?) throws {
        guard let id = arguments as? String else { throw FlutterErrorError.badArgument(String.self) }

        for case let region as CLCircularRegion in locationManager.monitoredRegions {
            if region.identifier == id {
                locationManager.stopMonitoring(for: region)
                break
            }
        }

        removeGeofenceName(id: id)
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        requestPermissionCallback?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        startMonitoringCallback?(nil)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                startMonitoringCallback?(FlutterErrorError.permissionDenied(error.localizedDescription))
            default:
                startMonitoringCallback?(FlutterErrorError.unknown("CLError \(error.code.rawValue): \(error.localizedDescription)"))
            }
        } else {
            startMonitoringCallback?(FlutterErrorError.unknown(error.localizedDescription))
        }
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .denied, .regionMonitoringDenied:
                startMonitoringCallback?(FlutterErrorError.permissionDenied(error.localizedDescription))
            case .regionMonitoringFailure:
                // Radius is checked to be within range in `startMonitoring`
                startMonitoringCallback?(FlutterErrorError.maximumGeofencesReached(error.localizedDescription))
            default:
                startMonitoringCallback?(FlutterErrorError.unknown("CLError \(error.code.rawValue): \(error.localizedDescription)"))
            }
        } else {
            startMonitoringCallback?(FlutterErrorError.unknown(error.localizedDescription))
        }
    }

    // MARK: Exposed to AppDelegate
    func geofenceTriggered(id: String) {
        let notificationContent = UNMutableNotificationContent()
        var title = getGeofenceName(id: id)
        if title == nil {
            title = id
            print("Could not retrieve geofence name")
        }
        notificationContent.title = title!
        notificationContent.body = "Schooler Reminder"
        notificationContent.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    // MARK: Internal helper functions
    private func region(forID id: String, lat: Double, lng: Double, radius: Int, geofenceEvent: GeofenceEvent) -> CLRegion {
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                                      radius: Double(radius),
                                      identifier: id)
        region.notifyOnEntry = geofenceEvent == .enter
        region.notifyOnExit = geofenceEvent == .exit

        return region
    }

    /// Key to the `UserDefaults` field of geofence names.
    private let GEOFENCE_NAMES_KEY = "GeofenceNames"
    /// Set the name of a geofence to UserDefaults with its ID.
    private func setGeofenceName(_ name: String, id: String) {
        var dict = UserDefaults.standard.dictionary(forKey: GEOFENCE_NAMES_KEY) ?? [:]
        dict[id] = name
        UserDefaults.standard.setValue(dict, forKey: GEOFENCE_NAMES_KEY)
    }
    /// Remove the name of a geofence in UserDefaults with its ID.
    private func removeGeofenceName(id: String) {
        var dict = UserDefaults.standard.dictionary(forKey: GEOFENCE_NAMES_KEY) ?? [:]
        dict.removeValue(forKey: id)
        UserDefaults.standard.setValue(dict, forKey: GEOFENCE_NAMES_KEY)
    }
    /// Retrieve the name of a geofence in UserDefaults with its ID.
    private func getGeofenceName(id: String) -> String? {
        let dict = UserDefaults.standard.dictionary(forKey: GEOFENCE_NAMES_KEY) ?? [:]
        return dict[id] as? String
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if (region is CLCircularRegion) { Geofencing.instance.geofenceTriggered(id: region.identifier) }
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if (region is CLCircularRegion) { Geofencing.instance.geofenceTriggered(id: region.identifier) }
    }
}
