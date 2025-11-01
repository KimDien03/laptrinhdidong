import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../config/mapbox_config.dart';

/// Mapbox access token for Android/iOS.
/// Provide it via --dart-define=MAPBOX_ACCESS_TOKEN=...
/// or update mapboxAccessToken in lib/config/mapbox_config.dart.

bool get _isDesktopPlatform =>
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.linux;

/// Platform-agnostic map widget.
class UniversalMap extends StatefulWidget {
  const UniversalMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15.0,
  });

  final double latitude;
  final double longitude;
  final double zoom;

  @override
  State<UniversalMap> createState() => _UniversalMapState();
}

class _UniversalMapState extends State<UniversalMap> {
  static const String _placeholderToken = 'pk.eyJ1Ijoia3V1aGFrdTEyODQiLCJhIjoiY21ndnIycjhlMHVoMTJzb2JtbGIyNndwdSJ9.ALikXkqeORf-18TFf4tBFQ';

  bool _mapboxFailed = false;
  bool _mapLoaded = false;

  bool get _isMapboxSupported => !kIsWeb && !_isDesktopPlatform;

  bool get _hasMapboxToken =>
      mapboxAccessToken.isNotEmpty &&
      !mapboxAccessToken.contains(_placeholderToken);

  bool get _shouldUseMapbox =>
      _isMapboxSupported && _hasMapboxToken && !_mapboxFailed;

  @override
  void initState() {
    super.initState();

    if (!_isMapboxSupported) {
      return;
    }

    if (!_hasMapboxToken) {
      _mapboxFailed = true;
      return;
    }

    _setAccessToken();
  }

  @override
  void didUpdateWidget(covariant UniversalMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_shouldUseMapbox &&
        (oldWidget.latitude != widget.latitude ||
            oldWidget.longitude != widget.longitude ||
            oldWidget.zoom != widget.zoom)) {
      _mapLoaded = false;
    }
  }

  Future<void> _setAccessToken() async {
    try {
      MapboxOptions.setAccessToken(mapboxAccessToken);
    } catch (error, stackTrace) {
      if (!_mapboxFailed) {
        debugPrint('Failed to initialise Mapbox access token: $error');
        debugPrintStack(stackTrace: stackTrace);
        setState(() {
          _mapboxFailed = true;
        });
      }
    }
  }

  void _handleMapLoaded(MapLoadedEventData _) {
    if (!_mapLoaded && mounted) {
      setState(() {
        _mapLoaded = true;
      });
    }
  }

  void _handleMapLoadError(MapLoadingErrorEventData event) {
    if (_mapboxFailed || !mounted) {
      return;
    }
    debugPrint('Mapbox map failed to load: ${event.type} ${event.message}');
    setState(() {
      _mapboxFailed = true;
      _mapLoaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldUseMapbox) {
      return _buildFallbackMap();
    }

    final Point center = Point(
      coordinates: Position(widget.longitude, widget.latitude),
    );

    // Use Mapbox on Android/iOS.
    return Stack(
      alignment: Alignment.center,
      children: [
        MapWidget(
          key: ValueKey(
            'map-${widget.latitude}-${widget.longitude}-${widget.zoom}',
          ),
          cameraOptions: CameraOptions(center: center, zoom: widget.zoom),
          styleUri: MapboxStyles.MAPBOX_STREETS,
          onMapLoadedListener: _handleMapLoaded,
          onMapLoadErrorListener: _handleMapLoadError,
        ),
        if (!_mapLoaded)
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0x11000000)),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        IgnorePointer(
          child: Icon(
            Icons.location_pin,
            color: Colors.red.shade600,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackMap() {
    // Use OpenStreetMap on Web/Desktop or whenever Mapbox is unavailable.
    return osm.FlutterMap(
      options: osm.MapOptions(
        initialCenter: LatLng(widget.latitude, widget.longitude),
        initialZoom: widget.zoom,
      ),
      children: [
        osm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.food_travel',
        ),
        osm.MarkerLayer(
          markers: [
            osm.Marker(
              point: LatLng(widget.latitude, widget.longitude),
              width: 40,
              height: 40,
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}
