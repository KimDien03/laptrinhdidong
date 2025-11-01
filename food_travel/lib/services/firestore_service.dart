import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/auth_account.dart';
import '../models/order_request.dart';
import '../models/place.dart';
import '../models/review.dart';
import '../models/user.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _placesCollection =>
      _firestore.collection('places');

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');

  Future<AuthAccount?> fetchAccount(String phoneNumber) async {
    final snapshot = await _usersCollection.doc(phoneNumber).get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data() ?? <String, dynamic>{};
    final passwordHash = data['passwordHash'] as String? ?? '';
    if (passwordHash.isEmpty) {
      return null;
    }
    return AuthAccount(
      phoneNumber: phoneNumber,
      displayName: data['displayName'] as String? ?? '',
      passwordHash: passwordHash,
      isAdmin: data['isAdmin'] as bool? ?? false,
    );
  }

  Future<TravelerUser?> fetchUserProfile(String phoneNumber) async {
    final snapshot = await _usersCollection.doc(phoneNumber).get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data() ?? <String, dynamic>{};
    return TravelerUser(
      id: phoneNumber,
      displayName: data['displayName'] as String? ?? 'Người dùng',
      isAdmin: data['isAdmin'] as bool? ?? false,
      phoneNumber: phoneNumber,
      favorites: Set<String>.from(
        (data['favorites'] as List<dynamic>? ?? const <dynamic>[]),
      ),
      searchHistory: List<String>.from(
        (data['searchHistory'] as List<dynamic>? ?? const <dynamic>[]),
      ),
    );
  }

  Future<TravelerUser> createAccount(AuthAccount account) async {
    final docRef = _usersCollection.doc(account.phoneNumber);
    await docRef.set(<String, dynamic>{
      'phoneNumber': account.phoneNumber,
      'displayName': account.displayName,
      'passwordHash': account.passwordHash,
      'isAdmin': account.isAdmin,
      'favorites': <String>[],
      'searchHistory': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return TravelerUser(
      id: account.phoneNumber,
      displayName: account.displayName,
      isAdmin: account.isAdmin,
      phoneNumber: account.phoneNumber,
    );
  }

  Future<void> updateUserFavorites(String userId, Set<String> favorites) async {
    await _usersCollection.doc(userId).update(<String, dynamic>{
      'favorites': favorites.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserSearchHistory(
    String userId,
    List<String> searchHistory,
  ) async {
    await _usersCollection.doc(userId).update(<String, dynamic>{
      'searchHistory': searchHistory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserDisplayName(String userId, String displayName) async {
    await _usersCollection.doc(userId).update(<String, dynamic>{
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Place>> loadPlaces({
    List<Place>? seedData,
    List<Review>? seedReviews,
  }) async {
    final snapshot = await _placesCollection.get();
    if (snapshot.docs.isEmpty && seedData != null && seedData.isNotEmpty) {
      await _seedPlaces(seedData, seedReviews ?? const <Review>[]);
      return seedData;
    }
    return snapshot.docs
        .map((doc) => _placeFromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Review>> loadReviewsForPlaces(List<Place> places) async {
    final tasks = places.map(
      (place) => _placesCollection.doc(place.id).collection('reviews').get(),
    );
    final results = await Future.wait(tasks);
    final List<Review> reviews = <Review>[];
    for (var index = 0; index < places.length; index++) {
      final place = places[index];
      final snapshot = results[index];
      for (final doc in snapshot.docs) {
        reviews.add(_reviewFromMap(place.id, doc.id, doc.data()));
      }
    }
    return reviews;
  }

  Future<void> addOrUpdatePlace(Place place) async {
    await _placesCollection.doc(place.id).set(
          _placeToMap(place),
          SetOptions(merge: true),
        );
  }

  Future<void> removePlace(String placeId) async {
    final docRef = _placesCollection.doc(placeId);
    final reviewsSnapshot = await docRef.collection('reviews').get();
    final batch = _firestore.batch();
    for (final reviewDoc in reviewsSnapshot.docs) {
      batch.delete(reviewDoc.reference);
    }
    batch.delete(docRef);
    await batch.commit();
  }

  Future<void> addReview(Review review) async {
    await _placesCollection
        .doc(review.placeId)
        .collection('reviews')
        .doc(review.id)
        .set(_reviewToMap(review));
  }

  Future<void> removeReview(String placeId, String reviewId) async {
    await _placesCollection
        .doc(placeId)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }

  Future<void> submitOrder(OrderRequest order) async {
    final batch = _firestore.batch();
    final data = order.toJson()
      ..['status'] = order.status
      ..['createdAt'] = FieldValue.serverTimestamp();

    final orderRef = _ordersCollection.doc(order.id);
    batch.set(orderRef, data);

    final placeOrderRef =
        _placesCollection.doc(order.placeId).collection('orders').doc(order.id);
    batch.set(placeOrderRef, data);

    await batch.commit();
  }

  Future<void> _seedPlaces(
    List<Place> places,
    List<Review> reviews,
  ) async {
    final batch = _firestore.batch();

    for (final place in places) {
      final placeRef = _placesCollection.doc(place.id);
      batch.set(placeRef, _placeToMap(place));

      final relatedReviews =
          reviews.where((review) => review.placeId == place.id);
      for (final review in relatedReviews) {
        final reviewRef = placeRef.collection('reviews').doc(review.id);
        batch.set(reviewRef, _reviewToMap(review));
      }
    }

    await batch.commit();
  }

  Place _placeFromMap(String id, Map<String, dynamic> data) {
    final categoryName = data['category'] as String? ?? PlaceCategory.cafe.name;
    final priceName = data['priceLevel'] as String? ?? PriceLevel.medium.name;
    final openingHoursData =
        (data['openingHours'] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>();

    return Place(
      id: id,
      name: data['name'] as String? ?? 'Địa điểm',
      category: PlaceCategory.values.firstWhere(
        (category) => category.name == categoryName,
        orElse: () => PlaceCategory.cafe,
      ),
      description: data['description'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      latitude: (data['latitude'] as num? ?? 0).toDouble(),
      longitude: (data['longitude'] as num? ?? 0).toDouble(),
      imageUrls: List<String>.from(
        (data['imageUrls'] as List<dynamic>? ?? const <dynamic>[]),
      ),
      phone: data['phone'] as String? ?? '',
      priceLevel: PriceLevel.values.firstWhere(
        (level) => level.name == priceName,
        orElse: () => PriceLevel.medium,
      ),
      averageSpend: (data['averageSpend'] as num? ?? 0).toDouble(),
      openingHours: openingHoursData
          .map(
            (item) => OpeningHours(
              day: item['day'] as String? ?? '',
              opensAt: item['opensAt'] as String? ?? '',
              closesAt: item['closesAt'] as String? ?? '',
            ),
          )
          .toList(),
      tags: List<String>.from(
        (data['tags'] as List<dynamic>? ?? const <dynamic>[]),
      ),
      website: data['website'] as String?,
    );
  }

  Map<String, dynamic> _placeToMap(Place place) {
    return <String, dynamic>{
      'name': place.name,
      'category': place.category.name,
      'description': place.description,
      'address': place.address,
      'city': place.city,
      'latitude': place.latitude,
      'longitude': place.longitude,
      'imageUrls': place.imageUrls,
      'phone': place.phone,
      'priceLevel': place.priceLevel.name,
      'averageSpend': place.averageSpend,
      'openingHours': place.openingHours
          .map(
            (hours) => <String, String>{
              'day': hours.day,
              'opensAt': hours.opensAt,
              'closesAt': hours.closesAt,
            },
          )
          .toList(),
      'tags': place.tags,
      'website': place.website,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Review _reviewFromMap(
    String placeId,
    String id,
    Map<String, dynamic> data,
  ) {
    final timestamp = data['createdAt'];
    return Review(
      id: id,
      placeId: placeId,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Ẩn danh',
      rating: (data['rating'] as num? ?? 0).toDouble(),
      comment: data['comment'] as String? ?? '',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.tryParse(timestamp?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> _reviewToMap(Review review) {
    return <String, dynamic>{
      'userId': review.userId,
      'userName': review.userName,
      'rating': review.rating,
      'comment': review.comment,
      'createdAt': Timestamp.fromDate(review.createdAt),
    };
  }
}
