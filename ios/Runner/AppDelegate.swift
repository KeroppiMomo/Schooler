import UIKit
import Flutter
import GoogleMaps
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    let locationManager = CLLocationManager()

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

       // Start of Geofencing
       let controller = window?.rootViewController as! FlutterViewController
       Geofencing.instance.initialize(controller: controller)
       locationManager.delegate = self
       // End of Geofencing

       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }


}
