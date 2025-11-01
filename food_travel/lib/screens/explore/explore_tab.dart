import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/filter_options.dart';
import '../../models/place.dart';
import '../../widgets/place_card.dart';
import '../../widgets/places_map_view.dart';
import '../place_detail/place_detail_screen.dart';
import '../trip_planner/trip_planner_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final List<_BrandBannerData> _banners = const [
    _BrandBannerData(
      title: 'Dang Phat | Food Travel Creator',
      description:
          'Chia se trai nghiem am thuc va hanh trinh kham pha dia phuong.',
      highlight: 'Theo doi vlog moi moi tuan',
      startColor: Color(0xFF0F9B8E),
      endColor: Color(0xFF097E6D),
    ),
    _BrandBannerData(
      title: 'Khoa hoc Travel Storytelling',
      description:
          'Tu y tuong den ke hoach noi dung chi trong 7 ngay voi template doc quyen.',
      highlight: 'Uu dai 20% cho hoc vien moi',
      startColor: Color(0xFFE86A92),
      endColor: Color(0xFFB23A65),
    ),
    _BrandBannerData(
      title: 'Hop tac quang ba diem den',
      description:
          'Tang do phu thuong hieu du lich voi chien dich noi dung da kenh.',
      highlight: 'Email: hello@dangphat.dev',
      startColor: Color(0xFF5B8DE1),
      endColor: Color(0xFF365BB6),
    ),
  ];

  int _currentBanner = 0;
  late final PageController _pageController;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (_banners.length <= 1) {
      return;
    }
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!_pageController.hasClients) {
        return;
      }
      final nextPage = (_currentBanner + 1) % _banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final places = state.filteredPlaces;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'Khám phá & Lên lịch trình',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Bo loc nang cao',
                onPressed: () => _openFilterSheet(context),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pushNamed(TripPlannerScreen.routeName);
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('Len lich trinh'),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kham pha tren ban do',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    PlacesMapView(
                      places: places.take(25).toList(),
                      onMarkerTap: (place) {
                        Navigator.of(context).pushNamed(
                          PlaceDetailScreen.routeName,
                          arguments: place.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildBrandCarousel(context),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Dia diem noi bat',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                ),
              ),
              const SizedBox(height: 12),
              if (places.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _EmptyState(
                    onClear: state.clearFilters,
                  ),
                )
              else
                ListView.builder(
                  itemCount: places.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemBuilder: (context, index) {
                    final place = places[index];
                    final isFavorite = state.favorites.contains(place.id);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: PlaceCard(
                        place: place,
                        isFavorite: isFavorite,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            PlaceDetailScreen.routeName,
                            arguments: place.id,
                          );
                        },
                        onFavorite: () => state.toggleFavorite(place.id),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrandCarousel(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            padEnds: false,
            onPageChanged: (index) {
              setState(() => _currentBanner = index);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1;
                  if (_pageController.hasClients &&
                      _pageController.position.haveDimensions) {
                    final page = _pageController.page ?? 0;
                    final distance = (page - index).abs();
                    scale = (1 - (distance * 0.12)).clamp(0.88, 1.0);
                  } else if (index != _currentBanner) {
                    scale = 0.92;
                  }
                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: child,
                      ),
                    ),
                  );
                },
                child: _BrandBannerCard(data: _banners[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = index == _currentBanner;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 18 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? theme.colorScheme.primary : Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _openFilterSheet(BuildContext context) {
    final appState = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _FilterSheet(
          options: appState.filterOptions,
          onApply: appState.applyFilters,
          onClear: appState.clearFilters,
        );
      },
    );
  }
}

class _BrandBannerCard extends StatelessWidget {
  const _BrandBannerCard({required this.data});

  final _BrandBannerData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [data.startColor, data.endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: data.endColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  data.highlight,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.filter_alt_off_rounded, color: Colors.teal, size: 28),
              SizedBox(width: 12),
              Text(
                'Khong tim thay dia diem phu hop',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Thu giam bo loc hoac xoa het loc de xem toan bo danh sach.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Dat lai bo loc'),
          ),
        ],
      ),
    );
  }
}

class _BrandBannerData {
  const _BrandBannerData({
    required this.title,
    required this.description,
    required this.highlight,
    required this.startColor,
    required this.endColor,
  });

  final String title;
  final String description;
  final String highlight;
  final Color startColor;
  final Color endColor;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.options,
    required this.onApply,
    required this.onClear,
  });

  final FilterOptions options;
  final ValueChanged<FilterOptions> onApply;
  final VoidCallback onClear;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<PlaceCategory> _selectedCategories;
  double? _minRating;
  PriceLevel? _maxPriceLevel;

  @override
  void initState() {
    super.initState();
    _selectedCategories =
        Set<PlaceCategory>.from(widget.options.selectedCategories);
    _minRating = widget.options.minRating;
    _maxPriceLevel = widget.options.maxPriceLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Bo loc nang cao',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon:
                      const Icon(Icons.restart_alt_rounded, color: Colors.teal),
                  tooltip: 'Dat lai',
                  onPressed: () {
                    setState(() {
                      _selectedCategories.clear();
                      _minRating = null;
                      _maxPriceLevel = null;
                    });
                    widget.onClear();
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: PlaceCategory.values
                  .map(
                    (category) => FilterChip(
                      label: Text(category.name),
                      selected: _selectedCategories.contains(category),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      selectedColor: Colors.teal[100],
                      checkmarkColor: Colors.teal[800],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<double>(
              decoration: const InputDecoration(
                labelText: 'Danh gia toi thieu',
                border: OutlineInputBorder(),
              ),
              value: _minRating,
              items: const [
                DropdownMenuItem(value: 3, child: Text('Tu 3 sao')),
                DropdownMenuItem(value: 4, child: Text('Tu 4 sao')),
                DropdownMenuItem(value: 4.5, child: Text('Tu 4.5 sao')),
              ],
              onChanged: (value) => setState(() => _minRating = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PriceLevel>(
              decoration: const InputDecoration(
                labelText: 'Gia toi da',
                border: OutlineInputBorder(),
              ),
              value: _maxPriceLevel,
              items: PriceLevel.values
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _maxPriceLevel = value),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  widget.onApply(
                    FilterOptions(
                      selectedCategories: _selectedCategories,
                      minRating: _minRating,
                      maxPriceLevel: _maxPriceLevel,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Ap dung bo loc'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
