import 'package:flutter/material.dart';
import './models/campus.dart';

/// Trang chi tiết hiển thị thông tin cụ thể của một campus
class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu campus được truyền từ HomeScreen và xử lý trường hợp null
    final campus = ModalRoute.of(context)?.settings.arguments as Campus?;
    
    if (campus == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No campus data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(campus.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hiển thị địa chỉ
            const Text('Địa chỉ:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(campus.address, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Hiển thị hình ảnh
            const Text('Hình ảnh:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Image.network(campus.image, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
