import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import 'models/auth_account.dart';
import 'models/filter_options.dart';
import 'models/order_request.dart';
import 'models/place.dart';
import 'models/place_distance.dart';
import 'models/review.dart';
import 'models/trip_plan.dart';
import 'models/user.dart';
import 'services/firestore_service.dart';
import 'services/location_service.dart';
import 'services/mock_data_service.dart';
import 'services/recommendation_service.dart';
import 'services/storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required MockDataService dataService,
    required LocationService locationService,
    required StorageService storageService,
    required RecommendationService recommendationService,
    required FirestoreService firestoreService,
  })  : _mockDataService = dataService,
        _locationService = locationService,
        _storageService = storageService,
        _recommendationService = recommendationService,
        _firestoreService = firestoreService;

  final MockDataService _mockDataService;
  final LocationService _locationService;
  final StorageService _storageService;
  final RecommendationService _recommendationService;
  final FirestoreService _firestoreService;
  final Uuid _uuid = const Uuid();

  final List<Place> _places = <Place>[];
  final List<Review> _reviews = <Review>[];
  final List<TripPlan> _plans = <TripPlan>[];
  TravelerUser? _currentUser;
  FilterOptions _filterOptions = FilterOptions.empty();
  LatLng? _currentLocation;
  bool _loading = true;
  String _searchQuery = '';
  TripPlan? _draftPlan;
  bool _nearbyUsedFallback = false;

  bool get isLoading => _loading;
  TravelerUser? get currentUser => _currentUser;
  LatLng? get currentLocation => _currentLocation;
  FilterOptions get filterOptions => _filterOptions;
  TripPlan? get draftPlan => _draftPlan;
  String get searchQuery => _searchQuery;
  bool get nearbyUsedFallback => _nearbyUsedFallback;

  List<Place> get allPlaces => List<Place>.unmodifiable(_places);
  List<Review> get allReviews => List<Review>.unmodifiable(_reviews);
  List<TripPlan> get plans => List<TripPlan>.unmodifiable(_plans);

  List<String> get searchHistory =>
      _currentUser?.searchHistory ?? const <String>[];

  Set<String> get favorites => _currentUser?.favorites ?? const <String>{};

  List<List<Place>> get combos =>
      _recommendationService.buildCombos(filteredPlaces);

  List<Place> get filteredPlaces {
    Iterable<Place> result = _places;
    if (_filterOptions.selectedCategories.isNotEmpty) {
      result = result.where(
        (place) => _filterOptions.selectedCategories.contains(place.category),
      );
    }
    if (_filterOptions.maxPriceLevel != null) {
      result = result.where(
        (place) =>
            place.priceLevel.index <= _filterOptions.maxPriceLevel!.index,
      );
    }
    if (_filterOptions.minRating != null) {
      result = result.where(
        (place) => place.averageRating >= _filterOptions.minRating!,
      );
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((place) => _matchesQuery(place, query));
    }
    return result.toList()
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));
  }

  List<Place> get favoritesPlaces {
    final favs = favorites;
    return _places.where((place) => favs.contains(place.id)).toList();
  }

  Future<List<PlaceDistance>> getNearbyPlaces({
    double radiusMeters = 2000,
  }) async {
    LatLng origin;
    try {
      origin = await _locationService.requirePreciseLocation();
    } on LocationPermissionException {
      _nearbyUsedFallback = false;
      rethrow;
    }

    var results = _computeNearbyPlaces(origin, radiusMeters);
    var usedFallback = false;

    if (results.isEmpty) {
      origin = _locationService.fallbackLocation;
      usedFallback = true;
      results = _computeNearbyPlaces(origin, radiusMeters * 4);
    }

    _currentLocation = origin;
    _nearbyUsedFallback = usedFallback;
    notifyListeners();
    return results;
  }

  List<PlaceDistance> _computeNearbyPlaces(
    LatLng origin,
    double radiusMeters,
  ) {
    final results = <PlaceDistance>[];
    for (final place in _places) {
      final distance =
          _locationService.distanceInMeters(origin, place.position);
      if (distance <= radiusMeters) {
        results.add(
          PlaceDistance(place: place, distanceMeters: distance),
        );
      }
    }
    results.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return results;
  }

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    try {
      final mockPlaces = _mockDataService.loadPlaces();
      final mockReviews = _mockDataService.loadReviews(mockPlaces);

      final remotePlaces = await _firestoreService.loadPlaces(
        seedData: mockPlaces,
        seedReviews: mockReviews,
      );
      final remoteReviews =
          await _firestoreService.loadReviewsForPlaces(remotePlaces);

      _places
        ..clear()
        ..addAll(remotePlaces);
      _reviews
        ..clear()
        ..addAll(remoteReviews.isEmpty ? mockReviews : remoteReviews);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'Firebase load failed, falling back to local data: '
          '$error\n$stackTrace',
        );
      }
      final fallbackPlaces = _mockDataService.loadPlaces();
      final fallbackReviews = _mockDataService.loadReviews(fallbackPlaces);
      _places
        ..clear()
        ..addAll(fallbackPlaces);
      _reviews
        ..clear()
        ..addAll(fallbackReviews);
    }

    _recomputeRatings();

    try {
      final savedPhone = await _storageService.loadCurrentAccountPhone();
      if (savedPhone != null) {
        _currentUser = await _firestoreService.fetchUserProfile(savedPhone);
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to restore previous session: $error');
      }
    }

    try {
      _currentLocation = await _locationService.getCurrentLocation();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unable to get current location: $error');
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<String?> registerAccount({
    required String phoneNumber,
    required String displayName,
    required String password,
    bool isAdmin = false,
  }) async {
    final normalizedPhone = phoneNumber.trim();
    if (normalizedPhone.isEmpty) {
      return 'Số điện thoại không hợp lệ';
    }

    try {
      final existing = await _firestoreService.fetchAccount(normalizedPhone);
      if (existing != null) {
        return 'Số điện thoại đã được đăng ký';
      }

      final account = AuthAccount(
        phoneNumber: normalizedPhone,
        displayName:
            displayName.trim().isEmpty ? 'Người dùng' : displayName.trim(),
        passwordHash: _hashPassword(password),
        isAdmin: isAdmin,
      );

      final user = await _firestoreService.createAccount(account);
      _currentUser = user;
      await _storageService.saveCurrentAccountPhone(normalizedPhone);
      notifyListeners();
      return null;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('registerAccount error: $error');
      }
      return 'Không thể tạo tài khoản. Vui lòng thử lại.';
    }
  }

  Future<String?> signInWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    final normalizedPhone = phoneNumber.trim();
    if (normalizedPhone.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    try {
      final account = await _firestoreService.fetchAccount(normalizedPhone);
      if (account == null) {
        return 'Số điện thoại chưa được đăng ký';
      }

      final hashedInput = _hashPassword(password);
      if (account.passwordHash != hashedInput) {
        return 'Mật khẩu không chính xác';
      }

      final user = await _firestoreService.fetchUserProfile(normalizedPhone) ??
          TravelerUser(
            id: normalizedPhone,
            displayName: account.displayName,
            isAdmin: account.isAdmin,
            phoneNumber: normalizedPhone,
          );

      _currentUser = user;
      await _storageService.saveCurrentAccountPhone(normalizedPhone);
      notifyListeners();
      return null;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('signInWithPhone error: $error');
      }
      return 'Không thể đăng nhập. Vui lòng thử lại.';
    }
  }

  Future<void> signOut() async {
    await _storageService.saveCurrentAccountPhone(null);
    _currentUser = null;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) {
      final user = _currentUser;
      if (user != null) {
        user.searchHistory.remove(query);
        user.searchHistory.insert(0, query);
        if (user.searchHistory.length > 10) {
          user.searchHistory.removeLast();
        }
        unawaited(_firestoreService.updateUserSearchHistory(
          user.id,
          user.searchHistory,
        ));
      }
    }
    notifyListeners();
  }

  List<Place> searchSuggestions(String query, {int limit = 6}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const <Place>[];
    }
    final matches = _places
        .where((place) => _matchesQuery(place, normalized))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    if (matches.length <= limit) {
      return matches;
    }
    return matches.sublist(0, limit);
  }

  void removeSearchHistoryItem(String query) {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    user.searchHistory.remove(query);
    unawaited(_firestoreService.updateUserSearchHistory(
      user.id,
      user.searchHistory,
    ));
    notifyListeners();
  }

  void applyFilters(FilterOptions options) {
    _filterOptions = options;
    notifyListeners();
  }

  void clearFilters() {
    _filterOptions = FilterOptions.empty();
    notifyListeners();
  }

  void toggleFavorite(String placeId) {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    if (user.favorites.contains(placeId)) {
      user.favorites.remove(placeId);
    } else {
      user.favorites.add(placeId);
    }
    unawaited(_firestoreService.updateUserFavorites(
      user.id,
      user.favorites,
    ));
    notifyListeners();
  }

  void addReview({
    required String placeId,
    required double rating,
    required String comment,
  }) {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    final review = Review(
      id: _uuid.v4(),
      placeId: placeId,
      userId: user.id,
      userName: user.displayName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.add(review);
    unawaited(_firestoreService.addReview(review));
    _recomputeRatings();
    notifyListeners();
  }

  void removeReview(String reviewId, {String? placeId}) {
    Review? removed;
    _reviews.removeWhere((review) {
      if (review.id == reviewId) {
        removed = review;
        return true;
      }
      return false;
    });
    if (removed != null) {
      final targetPlaceId = placeId ?? removed!.placeId;
      unawaited(_firestoreService.removeReview(targetPlaceId, removed!.id));
    }
    _recomputeRatings();
    notifyListeners();
  }

  void addOrUpdatePlace(Place place) {
    final index = _places.indexWhere((p) => p.id == place.id);
    if (index >= 0) {
      _places[index] = place;
    } else {
      _places.add(place);
    }
    unawaited(_firestoreService.addOrUpdatePlace(place));
    _recomputeRatings();
    notifyListeners();
  }

  void removePlace(String placeId) {
    _places.removeWhere((place) => place.id == placeId);
    _reviews.removeWhere((review) => review.placeId == placeId);
    final user = _currentUser;
    if (user != null) {
      user.favorites.remove(placeId);
      unawaited(_firestoreService.updateUserFavorites(
        user.id,
        user.favorites,
      ));
    }
    unawaited(_firestoreService.removePlace(placeId));
    _recomputeRatings();
    notifyListeners();
  }

  void createDraftPlan({
    required String title,
    required DateTime start,
    required DateTime end,
  }) {
    _draftPlan = TripPlan(
      id: _uuid.v4(),
      title: title,
      startDate: start,
      endDate: end,
    );
    notifyListeners();
  }

  void addStopToDraft({
    required String placeId,
    required DateTime date,
    String? note,
  }) {
    final plan = _draftPlan;
    if (plan == null) {
      return;
    }
    plan.stops.add(TripStop(placeId: placeId, date: date, note: note));
    notifyListeners();
  }

  void removeStopFromDraft(String placeId) {
    final plan = _draftPlan;
    if (plan == null) {
      return;
    }
    plan.stops.removeWhere((stop) => stop.placeId == placeId);
    notifyListeners();
  }

  void saveDraftPlan({String? notes}) {
    final plan = _draftPlan;
    if (plan == null) {
      return;
    }
    final saved = TripPlan(
      id: plan.id,
      title: plan.title,
      startDate: plan.startDate,
      endDate: plan.endDate,
      stops: List<TripStop>.from(plan.stops),
      notes: notes ?? plan.notes,
    );
    _plans.removeWhere((existing) => existing.id == saved.id);
    _plans.add(saved);
    _draftPlan = saved;
    notifyListeners();
  }

  Future<String?> submitOrderRequest({
    required Place place,
    required OrderType type,
    required String details,
    String? contactPhone,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return 'Bạn cần đăng nhập để gửi yêu cầu.';
    }
    final trimmedDetails = details.trim();
    if (trimmedDetails.isEmpty) {
      return 'Vui lòng mô tả chi tiết món hoặc yêu cầu booking.';
    }
    final phone = (contactPhone ?? user.phoneNumber ?? '').trim();
    if (phone.isEmpty) {
      return 'Vui lòng nhập số điện thoại liên hệ.';
    }

    final order = OrderRequest(
      id: _uuid.v4(),
      placeId: place.id,
      placeName: place.name,
      userId: user.id,
      userName: user.displayName,
      contactPhone: phone,
      type: type,
      details: trimmedDetails,
      createdAt: DateTime.now(),
    );

    try {
      await _firestoreService.submitOrder(order);
      return null;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('submitOrderRequest error: $error\n$stackTrace');
      }
      return 'Không thể gửi yêu cầu. Vui lòng thử lại sau.';
    }
  }

  bool _matchesQuery(Place place, String query) {
    final buffer = StringBuffer()
      ..write(place.name)
      ..write(' ')
      ..write(place.description)
      ..write(' ')
      ..write(place.address)
      ..write(' ')
      ..writeAll(place.tags, ' ');
    return buffer.toString().toLowerCase().contains(query);
  }

  void _recomputeRatings() {
    for (final place in _places) {
      final reviews =
          _reviews.where((review) => review.placeId == place.id).toList();
      if (reviews.isEmpty) {
        place.averageRating = 0;
        place.reviewCount = 0;
        continue;
      }
      final rating =
          reviews.fold<double>(0, (sum, review) => sum + review.rating) /
              reviews.length;
      place.averageRating = double.parse(rating.toStringAsFixed(1));
      place.reviewCount = reviews.length;
    }
  }

  String _hashPassword(String raw) {
    final bytes = utf8.encode(raw);
    return sha256.convert(bytes).toString();
  }
}
