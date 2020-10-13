import UIKit
import Flutter
import GoogleMaps
import CoreLocation
import workmanager

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
        
        // Start of Background Execution
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(6*60*60))
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }
        // End of Background Execution
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
