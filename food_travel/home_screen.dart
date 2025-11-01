import 'package:flutter/material.dart';
import './models/campus.dart';

/// Trang hiển thị danh sách các Campus
class HomeScreen extends StatelessWidget {
  // Lấy dữ liệu campus từ model
  final List<Campus> campuses = Campus.getCampuses();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Campus tại HUTECH')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dùng vòng for truyền thống để duyệt danh sách campus
            for (int i = 0; i < campuses.length; i++)
              Column(
                children: [
                  _buildCampusCard(
                    context,
                    campuses[i],
                  ), // Tạo Card cho từng campus
                  const SizedBox(height: 10), // Tạo khoảng cách giữa các card
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Hàm riêng để tạo Card hiển thị thông tin campus
  Widget _buildCampusCard(BuildContext context, Campus campus) {
    return Card(
      color: campus.color, // Dùng màu từ model
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.home, color: Colors.white), // Icon trang trí
            const SizedBox(width: 10),
            // Tên và địa chỉ campus
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campus.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    campus.address,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Nút chuyển sang trang chi tiết
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/details', // Route tới trang chi tiết
                  arguments: campus, // Truyền dữ liệu campus sang trang chi tiết
                );
              },
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
