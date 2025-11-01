import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../app_state.dart';
import '../../models/place.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/admin';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final user = state.currentUser;
        if (user == null || !user.isAdmin) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Bạn không có quyền truy cập khu vực này.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Bảng điều khiển'),
              bottom: const TabBar(
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Địa điểm'),
                  Tab(text: 'Đánh giá'),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openPlaceForm(context),
              label: const Text('Thêm địa điểm'),
              icon: const Icon(Icons.add_location_alt_rounded),
              backgroundColor: colorScheme.primary,
            ),
            body: const TabBarView(
              children: [
                _PlacesAdminTab(),
                _ReviewsAdminTab(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPlaceForm(BuildContext context, {Place? place}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: _PlaceForm(place: place),
        );
      },
    );
  }
}

class _PlacesAdminTab extends StatelessWidget {
  const _PlacesAdminTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final places = state.allPlaces;

    if (places.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có địa điểm nào.\nNhấn nút + để thêm mới.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(Icons.place_rounded, color: Colors.blueAccent),
            title: Text(
              place.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${place.displayCategory} • ${place.city}'),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 28,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 28,
                          ),
                          child: _PlaceForm(place: place),
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmRemove(context, place),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, Place place) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xóa địa điểm'),
          content: Text('Bạn chắc chắn muốn xóa "${place.name}" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                context.read<AppState>().removePlace(place.id);
                Navigator.of(context).pop();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}

class _ReviewsAdminTab extends StatelessWidget {
  const _ReviewsAdminTab();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final reviews = appState.allReviews;

    if (reviews.isEmpty) {
      return const Center(
        child: Text('Chưa có đánh giá nào.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        final place =
            appState.allPlaces.firstWhereOrNull((p) => p.id == review.placeId);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
              child: const Icon(Icons.reviews_rounded, color: Colors.blueAccent),
            ),
            title: Text(
              '${review.userName} • ${review.rating} ⭐',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${place?.name ?? "Không xác định"}\n${review.comment}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                context.read<AppState>().removeReview(review.id);
              },
            ),
          ),
        );
      },
    );
  }
}

class _PlaceForm extends StatefulWidget {
  const _PlaceForm({this.place});
  final Place? place;

  @override
  State<_PlaceForm> createState() => _PlaceFormState();
}

class _PlaceFormState extends State<_PlaceForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _website = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _price = TextEditingController();
  final _images = TextEditingController();
  final _tags = TextEditingController();
  PlaceCategory _category = PlaceCategory.restaurant;
  PriceLevel _priceLevel = PriceLevel.medium;

  @override
  void initState() {
    super.initState();
    final p = widget.place;
    if (p != null) {
      _name.text = p.name;
      _desc.text = p.description;
      _address.text = p.address;
      _city.text = p.city;
      _phone.text = p.phone;
      _website.text = p.website ?? '';
      _lat.text = p.latitude.toString();
      _lng.text = p.longitude.toString();
      _price.text = p.averageSpend.toString();
      _images.text = p.imageUrls.join(',');
      _tags.text = p.tags.join(',');
      _category = p.category;
      _priceLevel = p.priceLevel;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _address.dispose();
    _city.dispose();
    _phone.dispose();
    _website.dispose();
    _lat.dispose();
    _lng.dispose();
    _price.dispose();
    _images.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.place == null ? 'Thêm địa điểm mới' : 'Cập nhật địa điểm',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildField('Tên', _name, isRequired: true),
            _buildField('Mô tả', _desc, maxLines: 3),
            _buildField('Địa chỉ', _address),
            _buildField('Thành phố', _city),
            _dropdown<PlaceCategory>(
              label: 'Danh mục',
              value: _category,
              items: PlaceCategory.values,
              onChanged: (v) => setState(() => _category = v!),
            ),
            _dropdown<PriceLevel>(
              label: 'Mức giá',
              value: _priceLevel,
              items: PriceLevel.values,
              onChanged: (v) => setState(() => _priceLevel = v!),
            ),
            _buildField('Chi phí trung bình', _price,
                keyboard: TextInputType.number),
            _buildField('Liên hệ', _phone),
            _buildField('Website', _website),
            Row(
              children: [
                Expanded(child: _buildField('Vĩ độ (lat)', _lat)),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Kinh độ (lng)', _lng)),
              ],
            ),
            _buildField('Ảnh (URL, cách nhau bằng dấu phẩy)', _images),
            _buildField('Tag (cách nhau bằng dấu phẩy)', _tags),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => _save(context),
                icon: const Icon(Icons.save_rounded),
                label: Text(widget.place == null ? 'Thêm mới' : 'Lưu thay đổi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isRequired = false,
      int maxLines = 1,
      TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: isRequired
            ? (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null
            : null,
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((v) =>
                DropdownMenuItem(value: v, child: Text(v.toString().split('.').last)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();
    final id = widget.place?.id ?? const Uuid().v4();
    final openingHours = widget.place?.openingHours ??
        const [
          OpeningHours(day: 'Mon - Sun', opensAt: '08:00', closesAt: '22:00'),
        ];

    final place = Place(
      id: id,
      name: _name.text,
      category: _category,
      description: _desc.text,
      address: _address.text,
      city: _city.text,
      latitude: double.tryParse(_lat.text) ?? 0,
      longitude: double.tryParse(_lng.text) ?? 0,
      imageUrls: _images.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      phone: _phone.text,
      priceLevel: _priceLevel,
      averageSpend: double.tryParse(_price.text) ?? 0,
      openingHours: openingHours,
      tags: _tags.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      website: _website.text.isEmpty ? null : _website.text,
    );

    appState.addOrUpdatePlace(place);
    Navigator.of(context).pop();
  }
}
