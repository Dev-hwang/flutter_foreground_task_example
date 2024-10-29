import 'package:flutter/material.dart';

import '../controllers/main_page_controller.dart';

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
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Internal Plugin Service'),
      centerTitle: true,
    );
  }

  Widget _buildContent() {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: _controller.taskMessageListenable,
        builder: (BuildContext context, String? taskMessage, _) {
          return Text('taskMessage: $taskMessage');
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
