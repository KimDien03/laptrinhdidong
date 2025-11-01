import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/order_request.dart';
import '../../models/place.dart';
import '../../widgets/universal_map.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key});

  static const String routeName = '/place';

  @override
  Widget build(BuildContext context) {
    final placeId = ModalRoute.of(context)?.settings.arguments as String?;
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (placeId == null || state.allPlaces.isEmpty) {
          return const Scaffold(
            body: Center(
                child: Text(
                    'Kh\u00f4ng t\u00ecm th\u1ea5y \u0111\u1ecba \u0111i\u1ec3m')),
          );
        }

        final place = state.allPlaces.firstWhere(
          (item) => item.id == placeId,
          orElse: () => state.allPlaces.first,
        );

        final reviews = state.allReviews
            .where((review) => review.placeId == place.id)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Scaffold(
          appBar: AppBar(
            title: Text(place.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  state.favorites.contains(place.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () => state.toggleFavorite(place.id),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // \u1ea2nh
              SizedBox(
                height: 230,
                child: PageView.builder(
                  itemCount: place.imageUrls.length,
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      place.imageUrls[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Chip th\u00f4ng tin
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _buildChip(Icons.category, place.displayCategory),
                  _buildChip(Icons.star, '${place.averageRating} sao'),
                  _buildChip(Icons.payments_outlined, place.priceLabel()),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                place.description,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),

              const SizedBox(height: 20),
              _Section(
                title: 'Th\u00f4ng tin chi ti\u1ebft',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoTile(Icons.place_outlined, place.address),
                    _infoTile(Icons.phone_outlined, place.phone),
                    if (place.website != null)
                      _infoTile(Icons.language, place.website!),
                  ],
                ),
              ),

              _Section(
                title: 'Gi\u1edd m\u1edf c\u1eeda',
                child: Column(
                  children: place.openingHours
                      .map(
                        (entry) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(entry.day),
                          trailing: Text('${entry.opensAt} - ${entry.closesAt}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      )
                      .toList(),
                ),
              ),

              _Section(
                title: '\u0110\u1eb7t m\u00f3n ho\u1eb7c Booking',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'G\u1eedi y\u00eau c\u1ea7u \u0111\u1ec3 c\u1eeda h\u00e0ng x\u00e1c nh\u1eadn nhanh ch\u00f3ng. '
                      'Vui l\u00f2ng ghi r\u00f5 m\u00f3n c\u1ea7n \u0111\u1eb7t ho\u1eb7c s\u1ed1 ng\u01b0\u1eddi, th\u1eddi gian.',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openOrderSheet(context, place),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text(
                            'T\u1ea1o y\u00eau c\u1ea7u \u0111\u1eb7t'),
                      ),
                    ),
                  ],
                ),
              ),

              _Section(
                title: 'B\u1ea3n \u0111\u1ed3',
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: UniversalMap(
                      latitude: place.latitude,
                      longitude: place.longitude,
                      zoom: 14,
                    ),
                  ),
                ),
              ),

              _Section(
                title: '\u0110\u00e1nh gi\u00e1 & b\u00ecnh lu\u1eadn',
                action: TextButton.icon(
                  onPressed: () => _openReviewDialog(context, place.id),
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Vi\u1ebft \u0111\u00e1nh gi\u00e1'),
                ),
                child: reviews.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            'Ch\u01b0a c\u00f3 \u0111\u00e1nh gi\u00e1 n\u00e0o, h\u00e3y l\u00e0 ng\u01b0\u1eddi \u0111\u1ea7u ti\u00ean!'),
                      )
                    : Column(
                        children: reviews
                            .map(
                              (review) => Card(
                                elevation: 1.5,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.shade300,
                                    child: Text(
                                      review.userName[0].toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    '${review.userName} \u2013 ${review.rating}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    review.comment,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper: Chip \u0111\u1eb9p h\u01a1n
  Widget _buildChip(IconData icon, String text) {
    return Chip(
      backgroundColor: const Color(0xFFE8F5E9),
      avatar: Icon(icon, size: 18, color: const Color(0xFF388E3C)),
      label: Text(
        text,
        style: const TextStyle(color: Color(0xFF2E7D32)),
      ),
    );
  }

  // Helper: Th\u00f4ng tin chi ti\u1ebft
  Widget _infoTile(IconData icon, String text) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }

  void _openOrderSheet(BuildContext context, Place place) {
    final rootContext = context;
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    final phoneController =
        TextEditingController(text: user?.phoneNumber ?? '');
    final detailsController = TextEditingController();
    OrderType selectedType = OrderType.dine;
    bool isSubmitting = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'G\u1eedi y\u00eau c\u1ea7u cho ${place.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        ChoiceChip(
                          label: const Text('\u0110\u1eb7t b\u00e0n / Booking'),
                          selected: selectedType == OrderType.dine,
                          onSelected: (value) {
                            if (value) {
                              setState(() => selectedType = OrderType.dine);
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text(
                              '\u0110\u1eb7t m\u00f3n mang \u0111i/giao'),
                          selected: selectedType == OrderType.delivery,
                          onSelected: (value) {
                            if (value) {
                              setState(() => selectedType = OrderType.delivery);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText:
                            'S\u1ed1 \u0111i\u1ec7n tho\u1ea1i li\u00ean h\u1ec7',
                        prefixIcon: Icon(Icons.phone_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: selectedType == OrderType.dine
                            ? 'Th\u00f4ng tin booking (s\u1ed1 ng\u01b0\u1eddi, th\u1eddi gian...)'
                            : 'M\u00f3n c\u1ea7n \u0111\u1eb7t v\u00e0 y\u00eau c\u1ea7u th\u00eam',
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();
                                setState(() => isSubmitting = true);
                                final error = await rootContext
                                    .read<AppState>()
                                    .submitOrderRequest(
                                      place: place,
                                      type: selectedType,
                                      details: detailsController.text,
                                      contactPhone: phoneController.text,
                                    );
                                if (!context.mounted) {
                                  return;
                                }
                                setState(() => isSubmitting = false);
                                if (error != null) {
                                  ScaffoldMessenger.of(rootContext)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(modalContext).pop();
                                ScaffoldMessenger.of(rootContext).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '\u0110\u00e3 g\u1eedi y\u00eau c\u1ea7u. C\u1eeda h\u00e0ng s\u1ebd s\u1edbm li\u00ean h\u1ec7 x\u00e1c nh\u1eadn!',
                                    ),
                                  ),
                                );
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('G\u1eedi y\u00eau c\u1ea7u'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Dialog \u0111\u00e1nh gi\u00e1
  void _openReviewDialog(BuildContext context, String placeId) {
    final ratingController = TextEditingController();
    final commentController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
              '\u0110\u00e1nh gi\u00e1 \u0111\u1ecba \u0111i\u1ec3m'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(
                  labelText: 'S\u1ed1 sao (1-5)',
                  prefixIcon: Icon(Icons.star, color: Colors.amber),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'C\u1ea3m nh\u1eadn c\u1ee7a b\u1ea1n',
                  prefixIcon: Icon(Icons.comment_outlined),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('H\u1ee7y'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final rating = double.tryParse(ratingController.text) ?? 0;
                if (rating <= 0 || rating > 5) return;
                context.read<AppState>().addReview(
                      placeId: placeId,
                      rating: rating,
                      comment: commentController.text,
                    );
                Navigator.of(context).pop();
              },
              child: const Text('G\u1eedi'),
            ),
          ],
        );
      },
    );
  }
}

// Widget Section c\u00f3 style \u0111\u1eb9p h\u01a1n
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.action,
  });

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const Spacer(),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
