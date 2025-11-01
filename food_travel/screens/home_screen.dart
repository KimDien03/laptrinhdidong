import 'package:flutter/material.dart';
import '../models/campus.dart';

/// Trang hiển thị danh sách các Campus
class HomeScreen extends StatelessWidget {
  final List<Campus> campuses = Campus.getCampuses();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Cơ sở HUTECH',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF004AAD),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: campuses.length,
          itemBuilder: (context, index) {
            return _buildCampusCard(context, campuses[index]);
          },
        ),
      ),
    );
  }

  /// Hàm riêng để tạo Card hiển thị thông tin campus
  Widget _buildCampusCard(BuildContext context, Campus campus) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/details',
          arguments: campus,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh đại diện campus
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                campus.image,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  ),
                ),
              ),
            ),

            // Nội dung
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.location_city, color: campus.color, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campus.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          campus.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 18, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
