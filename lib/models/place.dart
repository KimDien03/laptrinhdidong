class Place {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  double? distance;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.distance,
  });

  Place copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? address,
    double? distance,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      distance: distance ?? this.distance,
    );
  }
}