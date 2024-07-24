import 'package:fl_location/fl_location.dart';
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
        title: const Text('Location Service'),
        centerTitle: true,
      ),
      body: _buildContentView(),
    );
  }

  Widget _buildContentView() {
    return Center(
      child: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: _controller.locationNotifier,
          builder: (BuildContext context, Location? location, _) {
            return _buildResultTable(location);
          },
        ),
      ),
    );
  }

  Widget _buildResultTable(Location? location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataTable(
          columns: const [
            DataColumn(label: Text('key')),
            DataColumn(label: Text('value')),
          ],
          rows: [
            DataRow(cells: _buildDataCells('latitude', location?.latitude)),
            DataRow(cells: _buildDataCells('longitude', location?.longitude)),
            DataRow(cells: _buildDataCells('accuracy', location?.accuracy)),
            DataRow(cells: _buildDataCells('altitude', location?.altitude)),
            DataRow(cells: _buildDataCells('heading', location?.heading)),
            DataRow(cells: _buildDataCells('speed', location?.speed)),
            DataRow(cells: _buildDataCells('timestamp', location?.timestamp)),
            DataRow(cells: _buildDataCells('isMock', location?.isMock)),
          ],
        ),
      ],
    );
  }

  List<DataCell> _buildDataCells(String key, dynamic value) {
    return [
      DataCell(Text(key)),
      DataCell(Text(value.toString())),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
