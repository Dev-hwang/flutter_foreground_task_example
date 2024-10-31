import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../config/constants.dart';

const String _kStopAction = 'action.stop';

@pragma('vm:entry-point')
void startRecordService() {
  FlutterForegroundTask.setTaskHandler(RecordServiceHandler());
}

class RecordServiceHandler extends TaskHandler {
  final AudioRecorder _recorder = AudioRecorder();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await _startRecorder();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // not use
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await _stopRecorder();
  }

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == _kStopAction) {
      FlutterForegroundTask.sendDataToMain('stop');
    }
  }

  Future<void> _startRecorder() async {
    // create record directory
    final Directory supportDir = await getApplicationSupportDirectory();
    final Directory recordDir =
        Directory(p.join(supportDir.path, Constants.recordDirectoryName));
    await recordDir.create(recursive: true);

    // determine file path
    final String currTime =
        DateFormat(Constants.recordFileNamePattern).format(DateTime.now());
    final String filePath = p.join(recordDir.path, '$currTime.m4a');

    // start recorder
    await _recorder.start(const RecordConfig(), path: filePath);

    // create stop action button
    FlutterForegroundTask.updateService(
      notificationText: 'recording..',
      notificationButtons: [
        const NotificationButton(id: _kStopAction, text: 'stop'),
      ],
    );
  }

  Future<void> _stopRecorder() async {
    // stop recorder
    await _recorder.stop();
    await _recorder.dispose();
  }
}
