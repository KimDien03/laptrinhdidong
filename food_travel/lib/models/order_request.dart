enum OrderType { dine, delivery }

class OrderRequest {
  OrderRequest({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.userId,
    required this.userName,
    required this.contactPhone,
    required this.type,
    required this.details,
    required this.createdAt,
    this.status = 'pending',
  });

  final String id;
  final String placeId;
  final String placeName;
  final String userId;
  final String userName;
  final String contactPhone;
  final OrderType type;
  final String details;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'placeId': placeId,
      'placeName': placeName,
      'userId': userId,
      'userName': userName,
      'contactPhone': contactPhone,
      'type': type.name,
      'details': details,
      'status': status,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
