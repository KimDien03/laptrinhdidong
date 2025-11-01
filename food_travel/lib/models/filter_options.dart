import 'place.dart';

class FilterOptions {
  FilterOptions({
    this.selectedCategories = const <PlaceCategory>{},
    this.maxDistanceKm,
    this.maxPriceLevel,
    this.minRating,
  });

  final Set<PlaceCategory> selectedCategories;
  final double? maxDistanceKm;
  final PriceLevel? maxPriceLevel;
  final double? minRating;

  FilterOptions copyWith({
    Set<PlaceCategory>? categories,
    double? maxDistance,
    PriceLevel? priceLevel,
    double? rating,
  }) {
    return FilterOptions(
      selectedCategories: categories ?? selectedCategories,
      maxDistanceKm: maxDistance ?? maxDistanceKm,
      maxPriceLevel: priceLevel ?? maxPriceLevel,
      minRating: rating ?? minRating,
    );
  }

  static FilterOptions empty() => FilterOptions();
}
