# location_service

An example of a background location service implementation using `flutter_foreground_task` and `fl_location`.

## Getting started

The plugins used in the project are as follows:

```yaml
dependencies:
  flutter_foreground_task: ^8.10.4
  fl_location: ^4.1.0
```

The settings for each platform are as follows:

### Android

* AndroidManifest.xml

```xml

<manifest>
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />

    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <application>
        <!-- Add service -->
        <service 
            android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
            android:foregroundServiceType="location" 
            android:exported="false" />
    </application>
</manifest>
```

### iOS

* Runner-Bridging-Header.h

```text
#import <flutter_foreground_task/FlutterForegroundTaskPlugin.h>
```

* AppDelegate.swift

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // add code
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback(registerPlugins)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// add func
func registerPlugins(registry: FlutterPluginRegistry) {
  GeneratedPluginRegistrant.register(with: registry)
}
```

* info.plist

```text
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to collect location data.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Used to collect location data in the background.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Used to collect location data in the background.</string>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.pravera.flutter_foreground_task.refresh</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>location</string>
</array>
```
