import 'package:flutter/material.dart';
import 'package:geofencing_api/geofencing_api.dart';

import '../controllers/main_page_controller.dart';
import 'region_state_card.dart';

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
      title: const Text('Geofencing Service'),
    );
  }

  Widget _buildContent() {
    return ValueListenableBuilder(
      valueListenable: _controller.geofenceStateListenable,
      builder: (context, geofenceState, _) {
        if (geofenceState == null) {
          return const SizedBox.shrink();
        }

        final List<GeofenceRegion> regions = geofenceState.regions.toList();
        final Location lastLocation = geofenceState.lastLocation;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: regions.length,
          itemBuilder: (context, index) {
            return RegionStateCard(
              region: regions[index],
              lastLocation: lastLocation,
            );
          },
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
