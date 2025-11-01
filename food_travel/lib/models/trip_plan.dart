class TripStop {
  TripStop({
    required this.placeId,
    required this.date,
    this.note,
  });

  final String placeId;
  final DateTime date;
  final String? note;
}

class TripPlan {
  TripPlan({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    List<TripStop>? stops,
    this.notes,
  }) : stops = stops ?? <TripStop>[];

  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripStop> stops;
  final String? notes;
}
