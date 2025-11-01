import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../widgets/place_card.dart';
import '../place_detail/place_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final favorites = state.favoritesPlaces;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Danh sách yêu thích',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF6F9F6),
          body: favorites.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final place = favorites[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PlaceCard(
                        place: place,
                        isFavorite: true,
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
        );
      },
    );
  }

  /// Hiển thị giao diện rỗng khi chưa có yêu thích
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 90,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có địa điểm yêu thích nào!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hãy thêm những địa điểm bạn thích vào danh sách để xem lại dễ dàng hơn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
