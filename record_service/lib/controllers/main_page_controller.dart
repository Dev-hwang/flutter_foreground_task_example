import 'package:flutter/material.dart';

import '../models/record_file_info.dart';
import '../models/record_status.dart';
import '../service/record_service.dart';
import '../ui/record_file_player.dart';
import '../utils/error_handler_mixin.dart';
import 'base_controller.dart';

class MainPageController extends BaseController with ErrorHandlerMixin {
  final recordStatusListenable =
      ValueNotifier(RecordService.instance.recordStatus);
  final recordFileInfoListListenable = ValueNotifier(<RecordFileInfo>[]);

  void startRecordService() {
    try {
      RecordService.instance.start();
    } catch (e, s) {
      handleError(e, s);
    }
  }

  void stopRecordService() {
    try {
      RecordService.instance.stop().then((_) => refreshRecordFileInfoList());
    } catch (e, s) {
      handleError(e, s);
    }
  }

  Future<void> refreshRecordFileInfoList() async {
    try {
      recordFileInfoListListenable.value =
          await RecordService.instance.getRecordFileInfoList();
    } catch (e, s) {
      handleError(e, s);
    }
  }

  void playRecordFile(RecordFileInfo fileInfo) {
    runIfStateIsAttached((state) {
      showDialog(
        context: state.context,
        builder: (_) => RecordFilePlayer(fileInfo: fileInfo),
      );
    });
  }

  void _onRecordStatusChanged(RecordStatus status) {
    recordStatusListenable.value = status;
  }

  @override
  void attach(State state) {
    super.attach(state);
    RecordService.instance
        .addRecordStatusChangedCallback(_onRecordStatusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshRecordFileInfoList();
    });
  }

  @override
  void dispose() {
    RecordService.instance
        .removeRecordStatusChangedCallback(_onRecordStatusChanged);
    recordStatusListenable.dispose();
    recordFileInfoListListenable.dispose();
    super.dispose();
  }
}
