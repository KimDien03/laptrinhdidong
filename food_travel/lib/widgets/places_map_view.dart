import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

/// Compact map that highlights a list of places using OpenStreetMap tiles.
class PlacesMapView extends StatelessWidget {
  const PlacesMapView({
    super.key,
    required this.places,
    this.onMarkerTap,
    this.height = 220,
  });

  final List<Place> places;
  final ValueChanged<Place>? onMarkerTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return _EmptyMapMessage(height: height);
    }

    final LatLng center = _calculateCenter();

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
          ),
          child: osm.FlutterMap(
            options: osm.MapOptions(
              initialCenter: center,
              initialZoom: 13,
              interactionOptions: const osm.InteractionOptions(
                flags: osm.InteractiveFlag.all &
                    ~osm.InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              osm.TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.food_travel',
              ),
              osm.MarkerLayer(
                markers: places
                    .map(
                      (place) => osm.Marker(
                        width: 44,
                        height: 44,
                        point: place.position,
                        child: _PlaceMarker(
                          place: place,
                          onTap: onMarkerTap,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LatLng _calculateCenter() {
    final double averageLat = places.fold<double>(
          0,
          (sum, place) => sum + place.latitude,
        ) /
        places.length;
    final double averageLng = places.fold<double>(
          0,
          (sum, place) => sum + place.longitude,
        ) /
        places.length;
    return LatLng(averageLat, averageLng);
  }
}

class _PlaceMarker extends StatelessWidget {
  const _PlaceMarker({
    required this.place,
    this.onTap,
  });

  final Place place;
  final ValueChanged<Place>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(place) : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                place.name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            Icons.location_pin,
            color: Colors.teal.shade600,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _EmptyMapMessage extends StatelessWidget {
  const _EmptyMapMessage({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.teal.shade100),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Ch\u01b0a c\u00f3 \u0111\u1ecba \u0111i\u1ec3m n\u00e0o \u0111\u1ec3 hi\u1ec3n th\u1ecb tr\u00ean b\u1ea3n \u0111\u1ed3.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.teal.shade800,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
