import 'package:geofencing_api/geofencing_api.dart';

class GeofenceState {
  GeofenceState({
    required this.regions,
    required this.lastLocation,
  });

  final Set<GeofenceRegion> regions;
  final Location lastLocation;

  factory GeofenceState.fromJson(Map<String, dynamic> json) {
    final regionsJson = json['regions'] as List;
    final regions = <GeofenceRegion>{};
    GeofenceRegion region;
    for (final regionJson in regionsJson) {
      region = GeofenceRegion.fromJson(regionJson);
      regions.add(region);
    }

    final lastLocationJson = json['lastLocation'];
    final lastLocation = Location.fromJson(lastLocationJson);

    return GeofenceState(regions: regions, lastLocation: lastLocation);
  }

  Map<String, dynamic> toJson() {
    return {
      'regions': regions.map((e) => e.toJson()).toList(),
      'lastLocation': lastLocation.toJson(),
    };
  }
}
