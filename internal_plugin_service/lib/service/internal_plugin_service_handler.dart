import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:internal_plugin/internal_plugin.dart';

@pragma('vm:entry-point')
void startInternalPluginService() {
  FlutterForegroundTask.setTaskHandler(InternalPluginServiceHandler());
}

class InternalPluginServiceHandler extends TaskHandler {
  int _count = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // some code
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    final String? platformVersion = await InternalPlugin().getPlatformVersion();
    _count++;

    // Update notification content.
    final String message = '$platformVersion ($_count)';
    FlutterForegroundTask.updateService(notificationText: message);

    // Send data to main isolate.
    FlutterForegroundTask.sendDataToMain(message);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // some code
  }
}
