import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/universal_map.dart';

/// Simple data model describing a cafe location.
class Cafe {
  const Cafe({
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.hours,
    required this.rating,
    required this.tags,
    required this.heroImageUrl,
    this.lat,
    this.lng,
  });

  final String name;
  final String description;
  final String address;
  final String phone;
  final String hours;
  final double rating;
  final List<String> tags;
  final String heroImageUrl;
  final double? lat;
  final double? lng;
}

/// Demo instance that mirrors the provided sample content.
const Cafe demoCafe = Cafe(
  name: 'Morning In Town',
  description:
      'Quan ca phe phong cach ban cong, phuc vu do uong dac san Da Lat va do an nhe.',
  address: '11 Trieu Viet Vuong, Da Lat, Vietnam',
  phone: '0263 3811 233',
  hours: 'Mon - Sun 07:00 - 21:30',
  rating: 4.3,
  tags: <String>['Quan ca phe', 'Trung binh'],
  heroImageUrl:
      'https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=1200&q=80',
  lat: 11.938047,
  lng: 108.444324,
);

/// Detail screen that showcases cafe information, photos, and map.
class CafeDetailPage extends StatelessWidget {
  const CafeDetailPage({super.key, required this.cafe});

  final Cafe cafe;

  static const Color _accentColor = Color(0xFFA4D7A1);
  static const Color _cardColor = Color(0xFFF4F8F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cardColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: _accentColor,
            surfaceTintColor: Colors.transparent,
            title: Text(
              cafe.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BannerSection(imageUrl: cafe.heroImageUrl),
                  const SizedBox(height: 16),
                  _ChipsSection(cafe: cafe),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    child: Text(
                      cafe.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.info_outline,
                          title: 'Thong tin chi tiet',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: cafe.address,
                          onTap: null,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.phone,
                          label: cafe.phone,
                          onTap: () => _launchPhone(cafe.phone, context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.schedule,
                          title: 'Gio mo cua',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cafe.hours,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    child: MapSection(cafe: cafe),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    child: _ReviewsSection(
                      cafeName: cafe.name,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 3,
      color: _cardColor,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Future<void> _launchPhone(String phone, BuildContext context) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(' ', ''),
    );
    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong the mo ung dung goi dien.')),
      );
    }
  }
}

/// Displays the hero image banner for the cafe.
class _BannerSection extends StatelessWidget {
  const _BannerSection({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.error_outline),
          ),
        ),
      ),
    );
  }
}

/// Shows quick fact chips for category, rating, and tag.
class _ChipsSection extends StatelessWidget {
  const _ChipsSection({required this.cafe});

  final Cafe cafe;

  static const Color _accentColor = Color(0xFFA4D7A1);

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(fontWeight: FontWeight.w600);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(
          icon: Icons.local_cafe,
          label: cafe.tags.isNotEmpty ? cafe.tags.first : 'Quan ca phe',
          style: labelStyle,
        ),
        _buildChip(
          icon: Icons.star_rounded,
          label: '${cafe.rating.toStringAsFixed(1)} sao',
          style: labelStyle,
        ),
        if (cafe.tags.length > 1)
          _buildChip(
            icon: Icons.notes_rounded,
            label: cafe.tags[1],
            style: labelStyle,
          ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    TextStyle? style,
  }) {
    return Chip(
      backgroundColor: _accentColor.withValues(alpha: 0.24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2F5D2D)),
          const SizedBox(width: 6),
          Text(label, style: style),
        ],
      ),
    );
  }
}

/// Reusable row for displaying an icon with a text value.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2F5D2D)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );

    if (onTap == null) return row;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: row,
      ),
    );
  }
}

/// Header row used inside cards to introduce a section.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2F5D2D)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Shows Google Maps for the cafe, resolving coordinates if needed.
class MapSection extends StatefulWidget {
  const MapSection({super.key, required this.cafe});

  final Cafe cafe;

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  late final Future<LatLng> _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = _resolveLocation();
  }

  Future<LatLng> _resolveLocation() async {
    if (widget.cafe.lat != null && widget.cafe.lng != null) {
      return LatLng(widget.cafe.lat!, widget.cafe.lng!);
    }
    try {
      final results = await locationFromAddress(widget.cafe.address);
      if (results.isEmpty) {
        throw Exception('Khong tim thay toa do.');
      }
      final first = results.first;
      return LatLng(first.latitude, first.longitude);
    } catch (error) {
      throw Exception('Khong the geocode dia chi: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: Icons.map_rounded, title: 'Ban do'),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 260,
            child: FutureBuilder<LatLng>(
              future: _locationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Khong the tai ban do: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final LatLng target = snapshot.requireData;

                return UniversalMap(
                  latitude: target.latitude,
                  longitude: target.longitude,
                  zoom: 15,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Displays a static list of demo reviews with an action button.
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.cafeName});

  final String cafeName;

  @override
  Widget build(BuildContext context) {
    final reviews = [
      (name: 'Thu Ha', score: 4.5, text: 'Ca phe ngon, khong gian yen tinh.'),
      (name: 'Minh Tri', score: 4.0, text: 'Nhan vien than thien, gia hop ly.'),
      (name: 'Bao Anh', score: 4.2, text: 'View ban cong dep, nhac chill.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.reviews_outlined,
          title: 'Danh gia & binh luan',
        ),
        const SizedBox(height: 12),
        ...reviews.map(
          (review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReviewCard(
              name: review.name,
              score: review.score,
              text: review.text,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Chuc nang dang phat trien cho ${reviewDisplayName(cafeName)}.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Viet danh gia'),
          ),
        ),
      ],
    );
  }

  String reviewDisplayName(String name) {
    if (name.isEmpty) return 'quan';
    return name;
  }
}

/// Individual review tile with rating badge.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.name,
    required this.score,
    required this.text,
  });

  final String name;
  final double score;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFA4D7A1),
              child: Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B3920),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example:
/// MaterialApp(
///   theme: ThemeData(
///     colorSchemeSeed: Color(0xFFA4D7A1),
///     useMaterial3: true,
///   ),
///   home: CafeDetailPage(cafe: demoCafe),
/// );
///
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => CafeDetailPage(cafe: demoCafe),
///   ),
/// );
