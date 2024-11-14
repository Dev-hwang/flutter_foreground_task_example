import 'package:flutter/material.dart';

import '../models/my_pedestrian_status.dart';
import '../models/my_step_count.dart';
import '../service/pedometer_service.dart';
import '../utils/error_handler_mixin.dart';
import 'base_controller.dart';

class MainPageController extends BaseController with ErrorHandlerMixin {
  final stepCountListenable = ValueNotifier<MyStepCount?>(null);
  final pedestrianStatusListenable = ValueNotifier<MyPedestrianStatus?>(null);

  void _startPedometerService() async {
    try {
      // already started
      if (await PedometerService.instance.isRunningService) {
        return;
      }

      PedometerService.instance.start();
    } catch (e, s) {
      handleError(e, s);
    }
  }

  void _onStepCount(MyStepCount stepCount) {
    stepCountListenable.value = stepCount;
  }

  void _onPedestrianStatusChanged(MyPedestrianStatus status) {
    pedestrianStatusListenable.value = status;
  }

  @override
  void attach(State state) {
    super.attach(state);
    PedometerService.instance.addStepCountCallback(_onStepCount);
    PedometerService.instance
        .addPedestrianStatusCallback(_onPedestrianStatusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPedometerService();
    });
  }

  @override
  void dispose() {
    PedometerService.instance.removeStepCountCallback(_onStepCount);
    PedometerService.instance
        .removePedestrianStatusCallback(_onPedestrianStatusChanged);
    stepCountListenable.dispose();
    pedestrianStatusListenable.dispose();
    super.dispose();
  }
}
