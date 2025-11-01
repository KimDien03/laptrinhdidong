import 'package:latlong2/latlong.dart';

enum PlaceCategory {
  restaurant,
  cafe,
  specialty,
  attraction,
  hotel,
  nightlife,
  experience,
}

enum PriceLevel { low, medium, high, luxury }

class OpeningHours {
  const OpeningHours({
    required this.day,
    required this.opensAt,
    required this.closesAt,
  });

  final String day;
  final String opensAt;
  final String closesAt;
}

class Place {
  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.phone,
    required this.priceLevel,
    required this.averageSpend,
    required this.openingHours,
    required this.tags,
    this.website,
  });

  final String id;
  final String name;
  final PlaceCategory category;
  final String description;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final String phone;
  final PriceLevel priceLevel;
  final double averageSpend;
  final List<OpeningHours> openingHours;
  final List<String> tags;
  final String? website;

  double averageRating = 0;
  int reviewCount = 0;

  LatLng get position => LatLng(latitude, longitude);

  String get displayCategory {
    switch (category) {
      case PlaceCategory.restaurant:
        return 'Nha hang';
      case PlaceCategory.cafe:
        return 'Quan ca phe';
      case PlaceCategory.specialty:
        return 'Dac san';
      case PlaceCategory.attraction:
        return 'Diem tham quan';
      case PlaceCategory.hotel:
        return 'Khach san';
      case PlaceCategory.nightlife:
        return 'Giai tri';
      case PlaceCategory.experience:
        return 'Trai nghiem';
    }
  }

  String priceLabel() {
    switch (priceLevel) {
      case PriceLevel.low:
        return 'Tiet kiem';
      case PriceLevel.medium:
        return 'Trung binh';
      case PriceLevel.high:
        return 'Cao cap';
      case PriceLevel.luxury:
        return 'Sang trong';
    }
  }

  Place copyWithRatings({required double rating, required int count}) {
    final cloned = Place(
      id: id,
      name: name,
      category: category,
      description: description,
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      imageUrls: List<String>.from(imageUrls),
      phone: phone,
      priceLevel: priceLevel,
      averageSpend: averageSpend,
      openingHours: List<OpeningHours>.from(openingHours),
      tags: List<String>.from(tags),
      website: website,
    );
    cloned.averageRating = rating;
    cloned.reviewCount = count;
    return cloned;
  }
}

