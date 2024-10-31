import 'package:flutter/material.dart';
import 'package:record_service/models/record_status.dart';

import '../controllers/main_page_controller.dart';
import '../models/record_file_info.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainPageController _controller = MainPageController();

  @override
  void initState() {
    super.initState();
    _controller.attach(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildContent(),
      floatingActionButton: _buildRecordServiceButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Record Service'),
      centerTitle: true,
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildRecordFileInfoListView(),
    );
  }

  Widget _buildRecordFileInfoListView() {
    return ValueListenableBuilder(
      valueListenable: _controller.recordFileInfoListListenable,
      builder: (context, fileInfoList, _) {
        return RefreshIndicator(
          onRefresh: _controller.refreshRecordFileInfoList,
          child: ListView.builder(
            itemCount: fileInfoList.length,
            itemBuilder: (context, index) =>
                _buildRecordFileInfoListItem(fileInfoList[index]),
          ),
        );
      },
    );
  }

  Widget _buildRecordFileInfoListItem(RecordFileInfo fileInfo) {
    return Card(
      child: InkWell(
        onTap: () => _controller.playRecordFile(fileInfo),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Text(fileInfo.name),
        ),
      ),
    );
  }

  Widget _buildRecordServiceButton() {
    return ValueListenableBuilder(
      valueListenable: _controller.recordStatusListenable,
      builder: (context, recordStatus, _) {
        final Widget child;
        final VoidCallback? onPressed;

        switch (recordStatus) {
          case RecordStatus.starting:
          case RecordStatus.stopping:
            child = const CircularProgressIndicator();
            onPressed = null;
            break;
          case RecordStatus.started:
            child = const Icon(Icons.stop);
            onPressed = _controller.stopRecordService;
            break;
          case RecordStatus.stopped:
            child = const Icon(Icons.fiber_manual_record, color: Colors.red);
            onPressed = _controller.startRecordService;
            break;
        }

        return FloatingActionButton(
          onPressed: onPressed,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
