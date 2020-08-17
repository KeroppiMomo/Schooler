import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)

    // Start of Google Maps Contents
    GMSServices.provideAPIKey("AIzaSyBZZXRwxMftrkdYZXCcLSi4wdEf2ztVwYA")
    // End of Google Maps Contents

    // Start of Local Notifications
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    // End of Local Notifications

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
