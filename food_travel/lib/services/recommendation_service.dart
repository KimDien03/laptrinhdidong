import '../models/place.dart';

class RecommendationService {
  List<List<Place>> buildCombos(List<Place> places) {
    final List<Place> food =
        places.where((p) => p.category == PlaceCategory.restaurant || p.category == PlaceCategory.specialty).toList();
    final List<Place> visit =
        places.where((p) => p.category == PlaceCategory.attraction || p.category == PlaceCategory.experience).toList();

    final List<List<Place>> combos = [];
    final int limit = food.length < visit.length ? food.length : visit.length;
    for (int i = 0; i < limit; i++) {
      combos.add([food[i], visit[i]]);
    }
    return combos;
  }
}
