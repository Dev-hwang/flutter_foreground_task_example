import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';

import '../models/my_pedestrian_status.dart';
import '../models/my_step_count.dart';

@pragma('vm:entry-point')
void startPedometerService() {
  FlutterForegroundTask.setTaskHandler(PedometerServiceHandler());
}

class PedometerServiceHandler extends TaskHandler {
  StreamSubscription<StepCount>? _stepCountSubs;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubs;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _stepCountSubs = Pedometer.stepCountStream.listen(_onStepCount);
    _pedestrianStatusSubs =
        Pedometer.pedestrianStatusStream.listen(_onPedestrianStatusChanged);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // not use
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _stepCountSubs?.cancel();
    _pedestrianStatusSubs?.cancel();
  }

  void _onStepCount(StepCount event) {
    final MyStepCount data =
        MyStepCount(steps: event.steps, timestamp: event.timeStamp);
    dev.log("PedometerServiceHandler::onStepCount: $event");

    FlutterForegroundTask.sendDataToMain(data.toJson());
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    final MyPedestrianStatus data =
        MyPedestrianStatus(status: event.status, timestamp: event.timeStamp);
    dev.log("PedometerServiceHandler::onPedestrianStatusChanged: $event");

    FlutterForegroundTask.sendDataToMain(data.toJson());
  }
}
