import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/nearby_places_service.dart';

class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({Key? key}) : super(key: key);

  @override
  _NearbyPlacesScreenState createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  final NearbyPlacesService _nearbyPlacesService = NearbyPlacesService();
  List<Place> _nearbyPlaces = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final places = await _nearbyPlacesService.getNearbyPlaces(2.0); // 2km radius
      setState(() {
        _nearbyPlaces = places;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places Within 2km'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyPlaces,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadNearbyPlaces,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_nearbyPlaces.isEmpty) {
      return const Center(
        child: Text('No places found within 2km'),
      );
    }

    return ListView.builder(
      itemCount: _nearbyPlaces.length,
      itemBuilder: (context, index) {
        final place = _nearbyPlaces[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: place.imageUrl.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: AssetImage(place.imageUrl),
                    onBackgroundImageError: (e, s) => Icon(Icons.error),
                  )
                : const Icon(Icons.place),
            title: Text(place.name),
            subtitle: Text(place.address),
            trailing: Text(
              '${place.distance?.toStringAsFixed(1) ?? "?"} km',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Navigate to place details
              // TODO: Implement navigation to details page
            },
          ),
        );
      },
    );
  }
}