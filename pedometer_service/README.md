# pedometer_service

An example of a pedometer service implementation using `flutter_foreground_task` and `pedometer`.

## Getting started

The plugins used in the project are as follows:

```yaml
dependencies:
  flutter_foreground_task: ^8.13.0
  pedometer: ^4.0.2
  permission_handler: ^11.3.1
```

The settings for each platform are as follows:

* AndroidManifest.xml

```xml
<manifest>
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_HEALTH" />

    <uses-permission android:name="android.permission.HIGH_SAMPLING_RATE_SENSORS" />
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />

    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

    <application>
        <!-- Add service -->
        <service 
            android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
            android:foregroundServiceType="health" 
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
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // this
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

* info.plist

```text
<key>NSMotionUsageDescription</key>
<string>This application tracks your steps</string>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.pravera.flutter_foreground_task.refresh</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
</array>
```
