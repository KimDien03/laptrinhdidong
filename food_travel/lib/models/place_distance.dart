import 'package:flutter/foundation.dart';

import 'place.dart';

@immutable
class PlaceDistance {
  const PlaceDistance({
    required this.place,
    required this.distanceMeters,
  });

  final Place place;
  final double distanceMeters;

  String formattedDistance() {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toStringAsFixed(0)} m';
  }
}
