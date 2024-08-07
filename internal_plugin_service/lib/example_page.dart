import 'package:flutter/material.dart';

import 'example_page_controller.dart';

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
        title: const Text('Internal Plugin Service'),
        centerTitle: true,
      ),
      body: _buildContentView(),
    );
  }

  Widget _buildContentView() {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: _controller.platformVersionNotifier,
        builder: (BuildContext context, String? platformVersion, _) {
          return Text('platformVersion: $platformVersion');
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
