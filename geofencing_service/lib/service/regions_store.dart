import 'dart:convert';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geofencing_api/geofencing_api.dart';

class RegionsStore {
  RegionsStore._();

  static final RegionsStore instance = RegionsStore._();

  Future<Set<GeofenceRegion>> getRegions() async {
    final Set<GeofenceRegion> regions = {};

    final Map<String, Object> data = await FlutterForegroundTask.getAllData();
    GeofenceRegion region;
    for (final Object value in data.values) {
      // check jsonString type
      if (value is! String) {
        continue;
      }

      region = GeofenceRegion.fromJson(jsonDecode(value));
      regions.add(region);
    }

    return regions;
  }

  Future<void> saveRegion(GeofenceRegion region) async {
    final String id = region.id;
    final String value = jsonEncode(region.toJson());
    await FlutterForegroundTask.saveData(key: id, value: value);
  }

  Future<void> removeRegionById(String id) async {
    await FlutterForegroundTask.removeData(key: id);
  }

  Future<void> clearRegions() async {
    await FlutterForegroundTask.clearAllData();
  }
}
