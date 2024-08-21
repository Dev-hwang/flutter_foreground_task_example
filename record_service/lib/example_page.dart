import 'package:flutter/material.dart';

import 'example_page_controller.dart';
import 'record_info.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<StatefulWidget> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final ExamplePageController _controller = ExamplePageController();

  @override
  void initState() {
    super.initState();
    _controller.attach(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Service'),
        centerTitle: true,
      ),
      body: _buildContentView(),
    );
  }

  Widget _buildContentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildRecordHistory()),
        _buildRecordButtons(),
      ],
    );
  }

  Widget _buildRecordHistory() {
    return ValueListenableBuilder(
      valueListenable: _controller.recordHistory,
      builder: (context, recordHistory, _) {
        return RefreshIndicator(
          onRefresh: _controller.refreshRecordHistory,
          child: ListView.builder(
            itemCount: recordHistory.length,
            itemBuilder: (context, index) =>
                _buildRecordHistoryItem(recordHistory[index]),
          ),
        );
      },
    );
  }

  Widget _buildRecordHistoryItem(RecordInfo recordInfo) {
    final BorderRadius radius = BorderRadius.circular(8.0);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: radius,
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () => _controller.onRecordHistoryItemPressed(recordInfo),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Text(recordInfo.name),
        ),
      ),
    );
  }

  Widget _buildRecordButtons() {
    return Material(
      elevation: 30,
      child: Padding(
        padding: const EdgeInsets.all(16)
            .copyWith(bottom: 16 + MediaQuery.of(context).padding.bottom),
        child: ValueListenableBuilder(
          valueListenable: _controller.isRunningService,
          builder: (context, isRunningService, _) {
            final Widget icon = isRunningService
                ? const Icon(Icons.stop)
                : const Icon(Icons.fiber_manual_record);
            final VoidCallback onPressed = isRunningService
                ? _controller.onRecordStopButtonPressed
                : _controller.onRecordStartButtonPressed;

            return Center(
              child: IconButton(
                iconSize: 96,
                icon: icon,
                onPressed: onPressed,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
