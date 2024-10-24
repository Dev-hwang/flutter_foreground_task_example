import 'package:flutter/material.dart';
import 'package:geofencing_api/geofencing_api.dart';

import '../../models/geofence_state.dart';
import '../../service/geofencing_service.dart';
import '../utils/error_handler_mixin.dart';
import 'base_controller.dart';

class MainPageController extends BaseController with ErrorHandlerMixin {
  final ValueNotifier<GeofenceState?> geofenceStateListenable =
      ValueNotifier(null);

  void _startGeofencingService() async {
    try {
      // already started
      if (await GeofencingService.instance.isRunningService) {
        return;
      }

      // dummy regions
      final Set<GeofenceRegion> regions = {
        GeofenceRegion.circular(
          id: 'region_1',
          data: {
            'name': 'National Museum of Korea',
          },
          center: const LatLng(37.523085, 126.979619),
          radius: 250,
        ),
        GeofenceRegion.polygon(
          id: 'region_2',
          data: {
            'name': 'Gyeongbokgung Palace',
          },
          polygon: [
            const LatLng(37.583696, 126.973739),
            const LatLng(37.583441, 126.979361),
            const LatLng(37.582506, 126.980198),
            const LatLng(37.579054, 126.979490),
            const LatLng(37.576112, 126.979061),
            const LatLng(37.576503, 126.974126),
            const LatLng(37.580959, 126.973568),
          ],
        ),
      };

      GeofencingService.instance.start(regions: regions);
    } catch (e, s) {
      handleError(e, s);
    }
  }

  void _onGeofenceStateChanged(GeofenceState state) {
    geofenceStateListenable.value = state;
  }

  @override
  void attach(State state) {
    super.attach(state);
    GeofencingService.instance.init();
    GeofencingService.instance.addCallback(_onGeofenceStateChanged);
    _startGeofencingService();
  }

  @override
  void dispose() {
    GeofencingService.instance.removeCallback(_onGeofenceStateChanged);
    geofenceStateListenable.dispose();
    super.dispose();
  }
}
