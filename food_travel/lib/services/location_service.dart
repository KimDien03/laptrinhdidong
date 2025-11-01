import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

const LatLng _dalatFallback = LatLng(11.940419, 108.458313);

class LocationPermissionException implements Exception {
  const LocationPermissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocationService {
  LatLng get fallbackLocation => _dalatFallback;

  Future<LatLng> getCurrentLocation() async {
    try {
      return await requirePreciseLocation();
    } on LocationPermissionException {
      return _dalatFallback;
    } catch (_) {
      return _dalatFallback;
    }
  }

  Future<LatLng> requirePreciseLocation() async {
    return _obtainCurrentLocation();
  }

  Future<LatLng?> tryGetPreciseLocation() async {
    try {
      return await _obtainCurrentLocation();
    } on LocationPermissionException {
      return null;
    } catch (_) {
      return null;
    }
  }

  double distanceInMeters(LatLng origin, LatLng target) {
    return Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      target.latitude,
      target.longitude,
    );
  }

  Future<LatLng> _obtainCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'Kh\u00f4ng th\u1ec3 l\u1ea5y v\u1ecb tr\u00ed hi\u1ec7n t\u1ea1i. '
        'Vui l\u00f2ng c\u1ea5p quy\u1ec1n truy c\u1eadp v\u1ecb tr\u00ed.',
      );
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } on LocationServiceDisabledException {
      throw const LocationPermissionException(
        'D\u1ecbch v\u1ee5 v\u1ecb tr\u00ed \u0111ang t\u1eaft. '
        'Vui l\u00f2ng b\u1eadt GPS tr\u00ean thi\u1ebft b\u1ecb.',
      );
    } catch (error) {
      throw LocationPermissionException(
        'Kh\u00f4ng th\u1ec3 l\u1ea5y v\u1ecb tr\u00ed hi\u1ec7n t\u1ea1i: $error',
      );
    }
  }
}
