import 'package:geolocator/geolocator.dart';
import '../models/place.dart';
import 'location_service.dart';

class NearbyPlacesService {
  final LocationService _locationService = LocationService();
  final List<Place> _places = [
    // Add some sample places here
    Place(
      id: '1',
      name: 'Cafe A',
      description: 'A cozy cafe with great coffee',
      imageUrl: 'assets/images/cafe_a.jpg',
      latitude: 10.7769,  // Example coordinates for Ho Chi Minh City
      longitude: 106.7009,
      address: '123 Le Loi Street, District 1, HCMC',
    ),
    // Add more places as needed
  ];

  Future<List<Place>> getNearbyPlaces(double radiusKm) async {
    try {
      final currentLocation = await _locationService.getCurrentLocation();
      if (currentLocation == null) {
        throw Exception('Could not get current location');
      }

      List<Place> nearbyPlaces = _places.map((place) {
        double distance = _locationService.calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          place.latitude,
          place.longitude,
        );
        
        return place.copyWith(distance: distance);
      }).where((place) => place.distance! <= radiusKm).toList();

      // Sort by distance
      nearbyPlaces.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
      
      return nearbyPlaces;
    } catch (e) {
      print('Error getting nearby places: $e');
      return [];
    }
  }
}