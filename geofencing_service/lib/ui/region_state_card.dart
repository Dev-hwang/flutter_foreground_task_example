import 'package:flutter/material.dart';
import 'package:geofencing_api/geofencing_api.dart';

class RegionStateCard extends StatelessWidget {
  const RegionStateCard({
    super.key,
    required this.region,
    required this.lastLocation,
  });

  final GeofenceRegion region;
  final Location lastLocation;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('id: ${region.id}'),
            Text('data: ${region.data}'),
            Text('status: ${region.status.name}'),
            Text('remaining: ${region.distanceTo(lastLocation).toInt()}m'),
          ],
        ),
      ),
    );
  }
}
