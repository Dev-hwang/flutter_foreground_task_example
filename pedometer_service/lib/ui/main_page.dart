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
      title: const Text('Pedometer Service'),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCountWidget(),
          const SizedBox(height: 32.0),
          _buildPedestrianStatusWidget(),
        ],
      ),
    );
  }

  Widget _buildStepCountWidget() {
    return ValueListenableBuilder(
      valueListenable: _controller.stepCountListenable,
      builder: (context, value, _) {
        final int? steps = value?.steps;

        return Column(
          children: [
            const Text('Steps Taken:'),
            Text('$steps', style: Theme.of(context).textTheme.headlineMedium),
          ],
        );
      },
    );
  }

  Widget _buildPedestrianStatusWidget() {
    return ValueListenableBuilder(
      valueListenable: _controller.pedestrianStatusListenable,
      builder: (context, value, _) {
        final String? status = value?.status;

        return Column(
          children: [
            const Text('Pedestrian Status:'),
            Text('$status', style: Theme.of(context).textTheme.headlineMedium),
            if (status != null) _buildPedestrianStatusIcon(status),
          ],
        );
      },
    );
  }

  Widget _buildPedestrianStatusIcon(String status) {
    final IconData iconData = switch (status) {
      "walking" => Icons.directions_walk,
      "stopped" => Icons.accessibility_new,
      _ => Icons.error,
    };

    return Icon(iconData, size: 100.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
