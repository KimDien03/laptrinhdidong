class Review {
  Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String placeId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
}
