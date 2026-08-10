import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../variables/variables.dart';

enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  mockDetected,
  error,
}

class GetLocation {
  Future<LocationStatus> getLocation({bool forceRequest = false}) async {
    try {
      Location location = Location();
      bool serviceEnabled;
      PermissionStatus permissionGranted;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return LocationStatus.serviceDisabled;
        }
      }

      permissionGranted = await location.hasPermission();

      // If permission is denied or we're forcing a request, request permission
      if (permissionGranted == PermissionStatus.denied ||
          permissionGranted == PermissionStatus.deniedForever ||
          forceRequest) {
        if (kDebugMode) {
          print(
            "Requesting location permission, current status: $permissionGranted",
          );
        }
        permissionGranted = await location.requestPermission();
        if (kDebugMode) {
          print("Permission request result: $permissionGranted");
        }

        if (permissionGranted == PermissionStatus.deniedForever) {
          return LocationStatus.permissionDeniedForever;
        }

        if (permissionGranted != PermissionStatus.granted) {
          return LocationStatus.permissionDenied;
        }
      } else if (permissionGranted == PermissionStatus.deniedForever) {
        return LocationStatus.permissionDeniedForever;
      }

      LocationData locationData = await location.getLocation();

      // Anti-spoofing: reject mocked GPS (replaces detect_fake_location).
      // isMock is populated from Android's Location.isFromMockProvider().
      if (locationData.isMock == true) {
        if (kDebugMode) print("Mock location detected");
        return LocationStatus.mockDetected;
      }

      if (kDebugMode) {
        print(
          "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}",
        );
      }

      lat = locationData.latitude;
      long = locationData.longitude;
      currtLocation = LatLng(locationData.latitude!, locationData.longitude!);

      return LocationStatus.success;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location: $e");
      }
      return LocationStatus.error;
    }
  }
}
