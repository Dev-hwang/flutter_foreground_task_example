import 'package:fl_location/fl_location.dart';
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
      title: const Text('Location Service'),
      centerTitle: true,
    );
  }

  Widget _buildContent() {
    return Center(
      child: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: _controller.locationListenable,
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
