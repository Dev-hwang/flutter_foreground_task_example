import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geofencing_api/geofencing_api.dart';
import 'package:geofencing_service/service/regions_store.dart';

import '../models/command_data.dart';
import '../models/geofence_state.dart';

@pragma('vm:entry-point')
void startGeofencingService() {
  FlutterForegroundTask.setTaskHandler(GeofencingServiceHandler());
}

class GeofencingServiceHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // setup
    Geofencing.instance.setup(allowsMockLocation: true);
    Geofencing.instance
        .addGeofenceStatusChangedListener(_onGeofenceStatusChanged);
    Geofencing.instance.addLocationChangedListener(_onLocationChanged);
    Geofencing.instance.addGeofenceErrorCallbackListener(_onGeofenceError);

    // get regions from share store
    final Set<GeofenceRegion> regions =
        await RegionsStore.instance.getRegions();

    // start geofencing service
    await Geofencing.instance.start(regions: regions);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // not use
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    Geofencing.instance
        .addGeofenceStatusChangedListener(_onGeofenceStatusChanged);
    Geofencing.instance.removeLocationChangedListener(_onLocationChanged);
    Geofencing.instance.addGeofenceErrorCallbackListener(_onGeofenceError);
    await Geofencing.instance.stop();
  }

  @override
  void onReceiveData(Object data) {
    if (CommandData.containsCommand(data)) {
      final CommandData commandData = data as CommandData;
      _handleCommandData(commandData);
    }
  }

  void _handleCommandData(CommandData commandData) {
    final Command command = commandData.command;
    final Object? data = commandData.data;
    if (command == Command.addRegion) {
      final regionJson = data as Map<String, dynamic>;
      final region = GeofenceRegion.fromJson(regionJson);
      Geofencing.instance.addRegion(region);
    } else if (command == Command.removeRegionById) {
      final regionId = data as String;
      Geofencing.instance.removeRegionById(regionId);
    } else if (command == Command.clearRegions) {
      Geofencing.instance.clearAllRegions();
    }
  }

  Future<void> _onLocationChanged(Location location) async {
    final GeofenceState geofenceState = GeofenceState(
      regions: Geofencing.instance.regions,
      lastLocation: location,
    );

    // Send data to geofencing_service.dart
    FlutterForegroundTask.sendDataToMain(geofenceState.toJson());
  }

  Future<void> _onGeofenceStatusChanged(
    GeofenceRegion geofenceRegion,
    GeofenceStatus geofenceStatus,
    Location location,
  ) async {
    _onLocationChanged(location);

    // Notifies the user that the geofence status has changed.
    // flutter_local_notifications or awesome_notifications
  }

  void _onGeofenceError(Object error, StackTrace stackTrace) {
    dev.log('geofence error: $error\n$stackTrace');
  }
}
