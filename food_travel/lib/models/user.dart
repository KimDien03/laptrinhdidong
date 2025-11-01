class TravelerUser {
  TravelerUser({
    required this.id,
    required this.displayName,
    required this.isAdmin,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    Set<String>? favorites,
    List<String>? searchHistory,
  })  : favorites = favorites ?? <String>{},
        searchHistory = searchHistory ?? <String>[];

  final String id;
  final String displayName;
  final bool isAdmin;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final Set<String> favorites;
  final List<String> searchHistory;

  String get contactDisplay => phoneNumber ?? email ?? '';
}
