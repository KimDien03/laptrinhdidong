import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/place.dart';
import '../../models/place_distance.dart';
import '../../services/location_service.dart';
import '../../widgets/place_card.dart';
import '../place_detail/place_detail_screen.dart';

const _accentColor = Color(0xFFA4D7A1);
const _surfaceColor = Color(0xFFF4F8F6);
const _debounceDuration = Duration(milliseconds: 500);
const _nearbyRadiusMeters = 2000.0;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<Place> _suggestions = const <Place>[];
  bool _showSuggestions = false;
  bool _isNearbyLoading = false;
  bool _nearbyActive = false;
  List<PlaceDistance> _nearbyPlaces = const <PlaceDistance>[];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value, AppState state) {
    _debounce?.cancel();
    setState(() {
      _showSuggestions = value.trim().isNotEmpty;
      _suggestions = state.searchSuggestions(value, limit: 8);
    });
    _debounce = Timer(_debounceDuration, () {
      state.updateSearchQuery(value);
    });
  }

  void _onSuggestionTap(Place place, AppState state) {
    _debounce?.cancel();
    _controller.text = place.name;
    state.updateSearchQuery(place.name);
    setState(() {
      _showSuggestions = false;
      _suggestions = const <Place>[];
    });
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushNamed(
      PlaceDetailScreen.routeName,
      arguments: place.id,
    );
  }

  void _clearQuery(AppState state) {
    _debounce?.cancel();
    _controller.clear();
    state.updateSearchQuery('');
    setState(() {
      _showSuggestions = false;
      _suggestions = const <Place>[];
    });
  }

  Future<void> _toggleNearby(AppState state) async {
    if (_nearbyActive) {
      setState(() {
        _nearbyActive = false;
        _nearbyPlaces = const <PlaceDistance>[];
      });
      return;
    }
    setState(() {
      _isNearbyLoading = true;
    });
    try {
      final places =
          await state.getNearbyPlaces(radiusMeters: _nearbyRadiusMeters);
      if (!mounted) return;
      if (places.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kh\u00f4ng t\u00ecm th\u1ea5y \u0111\u1ecba \u0111i\u1ec3m g\u1ea7n b\u1ea1n.',
            ),
          ),
        );
      } else {
        setState(() {
          _nearbyPlaces = places;
          _nearbyActive = true;
        });
        if (state.nearbyUsedFallback) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Hi\u1ec7n ch\u01b0a c\u00f3 d\u1eef li\u1ec7u \u1edf v\u1ecb tr\u00ed c\u1ee7a b\u1ea1n. '
                '\u0110ang hi\u1ec3n th\u1ecb g\u1ee3i \u00fd quanh \u0110\u00e0 L\u1ea1t.',
              ),
            ),
          );
        }
      }
    } on LocationPermissionException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Kh\u00f4ng th\u1ec3 l\u1ea5y v\u1ecb tr\u00ed: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNearbyLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final filteredPlaces = state.filteredPlaces;
        final favorites = state.favorites;
        final history = state.searchHistory;
        final combos = state.combos;
        final bool usedFallbackNearby = state.nearbyUsedFallback;

        final Set<String> filteredIds = {
          for (final place in filteredPlaces) place.id,
        };

        final List<PlaceDistance> activeNearby = _nearbyActive
            ? _nearbyPlaces
                .where((entry) => filteredIds.contains(entry.place.id))
                .toList()
            : const <PlaceDistance>[];

        final Map<String, double> distanceMap =
            _nearbyActive && !usedFallbackNearby
                ? {
                    for (final entry in activeNearby)
                      entry.place.id: entry.distanceMeters,
                  }
                : const <String, double>{};

        final List<Place> displayPlaces = _nearbyActive
            ? activeNearby.map((entry) => entry.place).toList()
            : filteredPlaces;

        final bool showEmptyMessage = displayPlaces.isEmpty;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'T\u00ecm ki\u1ebfm & g\u1ee3i \u00fd',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: _accentColor,
            foregroundColor: Colors.black87,
            elevation: 2,
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SearchBarWithSuggestions(
                  controller: _controller,
                  suggestions: _suggestions,
                  showSuggestions: _showSuggestions,
                  onChanged: (value) => _onQueryChanged(value, state),
                  onClear: () => _clearQuery(state),
                  onSuggestionTap: (place) => _onSuggestionTap(place, state),
                ),
                const SizedBox(height: 12),
                _NearbyButton(
                  active: _nearbyActive,
                  loading: _isNearbyLoading,
                  usedFallback: usedFallbackNearby,
                  onPressed: () => _toggleNearby(state),
                ),
                if (_nearbyActive && usedFallbackNearby)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Hi\u1ec7n ch\u01b0a c\u00f3 \u0111\u1ecba \u0111i\u1ec3m g\u1ea7n b\u1ea1n trong b\u1ea3n ghi. '
                          '\u0110ang hi\u1ec3n th\u1ecb g\u1ee3i \u00fd n\u1ed5i b\u1eadt quanh \u0110\u00e0 L\u1ea1t.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'L\u1ecdc nhanh',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: PlaceCategory.values
                      .map(
                        (category) => FilterChip(
                          label: Text(category.name),
                          selectedColor: _accentColor.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: _surfaceColor,
                          onSelected: (_) {
                            state.applyFilters(
                              state.filterOptions.copyWith(
                                categories: {category},
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    '\u0110\u00e3 t\u00ecm g\u1ea7n \u0111\u00e2y',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: history
                        .map(
                          (item) => InputChip(
                            label: Text(item),
                            backgroundColor: _surfaceColor,
                            deleteIconColor: Colors.redAccent,
                            onPressed: () {
                              _controller.text = item;
                              state.updateSearchQuery(item);
                            },
                            onDeleted: () {
                              state.removeSearchHistoryItem(item);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Combo \u1ea9m th\u1ef1c + du l\u1ecbch',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const SizedBox(height: 8),
                ...combos.map((combo) {
                  if (combo.length < 2) return const SizedBox.shrink();
                  final food = combo[0];
                  final visit = combo[1];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(
                        Icons.local_dining,
                        color: Color(0xFF2F5D2D),
                        size: 30,
                      ),
                      title: Text(
                        '${food.name} + ${visit.name}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${food.displayCategory} & ${visit.displayCategory}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.teal),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          PlaceDetailScreen.routeName,
                          arguments: food.id,
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Text(
                  _nearbyActive
                      ? (usedFallbackNearby
                          ? 'G\u1ee3i \u00fd n\u1ed5i b\u1eadt'
                          : '\u0110\u1ecba \u0111i\u1ec3m g\u1ea7n b\u1ea1n')
                      : 'K\u1ebft qu\u1ea3',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const SizedBox(height: 8),
                if (showEmptyMessage)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Kh\u00f4ng t\u00ecm th\u1ea5y \u0111\u1ecba \u0111i\u1ec3m ph\u00f9 h\u1ee3p.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  _CafeList(
                    places: displayPlaces,
                    favorites: favorites,
                    distanceMap: distanceMap,
                    highlightNearby: _nearbyActive && !usedFallbackNearby,
                    onFavoriteToggle: (placeId) =>
                        state.toggleFavorite(placeId),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchBarWithSuggestions extends StatelessWidget {
  const _SearchBarWithSuggestions({
    required this.controller,
    required this.suggestions,
    required this.showSuggestions,
    required this.onChanged,
    required this.onClear,
    required this.onSuggestionTap,
  });

  final TextEditingController controller;
  final List<Place> suggestions;
  final bool showSuggestions;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<Place> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _accentColor.withValues(alpha: 0.6)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText:
                'T\u00ecm theo t\u00ean, lo\u1ea1i, \u0111\u1ecba \u0111i\u1ec3m...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF2F5D2D)),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: onClear,
                  ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide:
                  const BorderSide(color: Color(0xFF2F5D2D), width: 1.8),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: showSuggestions
              ? Container(
                  key: const ValueKey('suggestions'),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: suggestions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Kh\u00f4ng t\u00ecm th\u1ea5y \u0111\u1ecba \u0111i\u1ec3m ph\u00f9 h\u1ee3p.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final place = suggestions[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: Text(place.name),
                              subtitle: Text(
                                place.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => onSuggestionTap(place),
                            );
                          },
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, indent: 16, endIndent: 16),
                          itemCount: suggestions.length,
                        ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NearbyButton extends StatelessWidget {
  const _NearbyButton({
    required this.active,
    required this.loading,
    required this.usedFallback,
    required this.onPressed,
  });

  final bool active;
  final bool loading;
  final bool usedFallback;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final String label;
    if (loading) {
      label = '\u0110ang x\u00e1c \u0111\u1ecbnh v\u1ecb tr\u00ed...';
    } else if (active) {
      label = usedFallback
          ? 'G\u1ee3i \u00fd quanh \u0110\u00e0 L\u1ea1t'
          : '\u0110ang hi\u1ec3n th\u1ecb g\u1ea7n b\u1ea1n';
    } else {
      label = 'G\u1ea7n t\u00f4i (2 km)';
    }

    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.location_on,
              color: active ? Colors.white : const Color(0xFF2F5D2D),
            ),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: active ? const Color(0xFF2F5D2D) : _surfaceColor,
        foregroundColor: active ? Colors.white : const Color(0xFF2F5D2D),
      ),
    );
  }
}

class _CafeList extends StatelessWidget {
  const _CafeList({
    required this.places,
    required this.favorites,
    required this.distanceMap,
    required this.highlightNearby,
    required this.onFavoriteToggle,
  });

  final List<Place> places;
  final Set<String> favorites;
  final Map<String, double> distanceMap;
  final bool highlightNearby;
  final ValueChanged<String> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: places
          .map(
            (place) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: PlaceCard(
                place: place,
                isFavorite: favorites.contains(place.id),
                distanceMeters: distanceMap[place.id],
                highlightNearby:
                    highlightNearby && distanceMap.containsKey(place.id),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    PlaceDetailScreen.routeName,
                    arguments: place.id,
                  );
                },
                onFavorite: () => onFavoriteToggle(place.id),
              ),
            ),
          )
          .toList(),
    );
  }
}
