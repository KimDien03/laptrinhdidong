import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/trip_plan.dart';
import '../place_detail/place_detail_screen.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  static const String routeName = '/trip-planner';

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final DateFormat _format = DateFormat('dd/MM');

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final draft = state.draftPlan;
        final plans = state.plans;
        final places = state.filteredPlaces;
        final hasDraft = draft != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Lên kế hoạch chuyến đi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 3,
            centerTitle: true,
          ),
          backgroundColor: Colors.grey[50],
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🌿 Tạo lịch trình mới
              ElevatedButton.icon(
                onPressed: () => _createPlan(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tạo lịch trình mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),

              // 📝 Lịch trình đang soạn
              if (draft != null)
                _DraftPlanCard(
                  plan: draft,
                  onSave: (notes) {
                    state.saveDraftPlan(notes: notes);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu lịch trình')),
                    );
                  },
                  onRemoveStop: state.removeStopFromDraft,
                ),

              // 📅 Lịch trình đã lưu
              if (plans.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Lịch trình đã lưu',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(),
                const SizedBox(height: 8),
                ...plans.map(
                  (plan) => Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.event_note,
                          color: Colors.teal, size: 30),
                      title: Text(plan.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      subtitle: Text(
                        '${_format.format(plan.startDate)} - ${_format.format(plan.endDate)} • ${plan.stops.length} điểm đến',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ],

              // 💡 Gợi ý kết hợp
              const SizedBox(height: 24),
              Text('Gợi ý kết hợp',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 8),
              ...state.combos.map(
                (combo) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb_outline,
                        color: Colors.teal),
                    title: Text('${combo[0].name} + ${combo[1].name}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${combo[0].displayCategory} cùng ${combo[1].displayCategory}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.teal),
                      onPressed: () {
                        if (!hasDraft) {
                          _promptCreateDraft(context);
                          return;
                        }
                        final now = DateTime.now();
                        state.addStopToDraft(
                            placeId: combo[0].id, date: now);
                        state.addStopToDraft(
                            placeId: combo[1].id,
                            date: now.add(const Duration(hours: 4)));
                      },
                    ),
                  ),
                ),
              ),

              // 📍 Tất cả địa điểm
              const SizedBox(height: 24),
              Text('Tất cả địa điểm',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 8),
              ...places.map(
                (place) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading:
                        const Icon(Icons.place_outlined, color: Colors.teal),
                    title: Text(place.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle:
                        Text('${place.displayCategory} • ${place.priceLabel()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add, color: Colors.teal),
                      onPressed: () {
                        if (!hasDraft) {
                          _promptCreateDraft(context);
                          return;
                        }
                        final now = DateTime.now();
                        state.addStopToDraft(placeId: place.id, date: now);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm ${place.name} vào lịch trình'),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        PlaceDetailScreen.routeName,
                        arguments: place.id,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _promptCreateDraft(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tạo lịch trình trước khi thêm địa điểm')),
    );
  }

  Future<void> _createPlan(BuildContext context) async {
    final titleController = TextEditingController();
    final appState = context.read<AppState>();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (range == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tên lịch trình'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Ví dụ: Một ngày ở Đà Lạt',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      appState.createDraftPlan(
        title: titleController.text.isEmpty
            ? 'Chuyến đi mới'
            : titleController.text,
        start: range.start,
        end: range.end,
      );
    }
  }
}

// 🎒 Widget: Thẻ lịch trình đang soạn
class _DraftPlanCard extends StatefulWidget {
  const _DraftPlanCard({
    required this.plan,
    required this.onSave,
    required this.onRemoveStop,
  });

  final TripPlan plan;
  final ValueChanged<String?> onSave;
  final void Function(String placeId) onRemoveStop;

  @override
  State<_DraftPlanCard> createState() => _DraftPlanCardState();
}

class _DraftPlanCardState extends State<_DraftPlanCard> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.plan.notes ?? '';
  }

  @override
  void didUpdateWidget(covariant _DraftPlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan.id != widget.plan.id ||
        oldWidget.plan.notes != widget.plan.notes) {
      _noteController.text = widget.plan.notes ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final format = DateFormat('dd/MM HH:mm');

    return Card(
      color: Colors.teal.shade50,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.plan.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              '${format.format(widget.plan.startDate)} - ${format.format(widget.plan.endDate)}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            if (widget.plan.stops.isEmpty)
              const Text('Thêm địa điểm để hoàn thiện lịch trình'),
            ...widget.plan.stops.map(
              (stop) {
                final place = appState.allPlaces
                    .firstWhereOrNull((p) => p.id == stop.placeId);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined,
                      color: Colors.teal),
                  title: Text(place?.name ?? stop.placeId),
                  subtitle: Text(format.format(stop.date)),
                  trailing: IconButton(
                    icon:
                        const Icon(Icons.close_rounded, color: Colors.redAccent),
                    onPressed: () => widget.onRemoveStop(stop.placeId),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => widget.onSave(_noteController.text),
                icon: const Icon(Icons.save_rounded),
                label: const Text('Lưu lịch trình'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
