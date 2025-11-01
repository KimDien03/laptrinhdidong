import 'package:flutter/material.dart';

import '../models/place.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    required this.onFavorite,
    required this.isFavorite,
    this.distanceMeters,
    this.highlightNearby = false,
  });

  final Place place;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isFavorite;
  final double? distanceMeters;
  final bool highlightNearby;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showNearby = highlightNearby && distanceMeters != null;
    final String? distanceLabel = distanceMeters == null
        ? null
        : distanceMeters! >= 1000
            ? '${(distanceMeters! / 1000).toStringAsFixed(1)} km'
            : '${distanceMeters!.toStringAsFixed(0)} m';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 88,
                  width: 88,
                  child: place.imageUrls.isNotEmpty
                      ? Image.network(place.imageUrls.first,
                          fit: BoxFit.cover)
                      : Container(color: theme.colorScheme.surfaceVariant),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showNearby)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFA4D7A1).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Gan ban',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1B3920),
                                ),
                              ),
                            ),
                            if (distanceLabel != null) ...[
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.place_rounded,
                                    size: 14,
                                    color: Color(0xFF2F5D2D),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    distanceLabel,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: onFavorite,
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(place.displayCategory,
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 16,
                            color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text('${place.averageRating} (${place.reviewCount})'),
                        const SizedBox(width: 12),
                        Icon(Icons.payments_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(place.priceLabel()),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (place.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: place.tags
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
