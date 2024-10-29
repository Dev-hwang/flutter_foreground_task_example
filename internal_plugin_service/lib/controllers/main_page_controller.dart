import 'package:flutter/widgets.dart';

import '../service/internal_plugin_service.dart';
import '../utils/error_handler_mixin.dart';
import 'base_controller.dart';

class MainPageController extends BaseController with ErrorHandlerMixin {
  final ValueNotifier<String?> taskMessageListenable = ValueNotifier(null);

  void _startInternalPluginService() async {
    try {
      // already started
      if (await InternalPluginService.instance.isRunningService) {
        return;
      }

      InternalPluginService.instance.start();
    } catch (e, s) {
      handleError(e, s);
    }
  }

  void _onTaskMessage(String message) {
    taskMessageListenable.value = message;
  }

  @override
  void attach(State state) {
    super.attach(state);
    InternalPluginService.instance.addTaskMessageCallback(_onTaskMessage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInternalPluginService();
    });
  }

  @override
  void dispose() {
    InternalPluginService.instance.removeTaskMessageCallback(_onTaskMessage);
    taskMessageListenable.dispose();
    super.dispose();
  }
}
