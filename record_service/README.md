# record_service

An example of a voice record service implementation using `flutter_foreground_task` and `record`.

## Getting started

The plugins used in the project are as follows:

```yaml
dependencies:
  flutter_foreground_task: ^8.6.0
  record: ^5.1.2
```

The settings for each platform are as follows:

### Android

* AndroidManifest.xml

```xml

<manifest>
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />

    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <application>
        <!-- Add service -->
        <service
            android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
            android:foregroundServiceType="microphone"
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
<key>NSMicrophoneUsageDescription</key>
<string>Used to record voice.</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>fetch</string>
</array>
```
