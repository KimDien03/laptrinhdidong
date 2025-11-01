import 'package:flutter/material.dart';

/// Lớp Campus lưu trữ thông tin cho từng cơ sở HUTECH
class Campus {
  final String name; // Tên campus
  final String address; // Địa chỉ
  final String image; // Link ảnh
  final Color color; // Màu nền đại diện

  Campus({
    required this.name,
    required this.address,
    required this.image,
    required this.color,
  });

  /// Hàm static trả về danh sách campus mẫu
  static List<Campus> getCampuses() {
    return [
      Campus(
        name: 'Saigon Campus',
        address: '475A Điện Biên Phủ, P.25, Q.Bình Thạnh, TP.HCM',
        image:
            'https://file1.hutech.edu.vn/file/editor/homepage1/Phoi%20canh%20co%20so%20Hutech_co%20so%20DBP%20%20.jpg',
        color: Colors.deepOrange,
      ),
      Campus(
        name: 'Ung Van Khiem Campus',
        address: '31/36 Ung Văn Khiêm, P.25, Q.Bình Thạnh, TP.HCM',
        image:
            'https://file1.hutech.edu.vn/file/editor/homepage1/ung-van-khiem.jpg',
        color: Colors.green,
      ),
      Campus(
        name: 'Thu Duc Campus',
        address: 'Khu Công nghệ cao TP.HCM, Xa lộ Hà Nội, TP. Thủ Đức',
        image:
            'https://file1.hutech.edu.vn/file/editor/homepage/stories/hinh202-hhh/Trung%20tam%20DTNNL%202.jpg',
        color: Colors.blue,
      ),
      Campus(
        name: 'Hitech Park Campus',
        address: 'Khu Công nghệ cao TP.HCM, P. Long Thạnh Mỹ, TP. Thủ Đức',
        image:
            'https://file1.hutech.edu.vn/file/editor/homepage/stories/hinh202-hhh/Vien-cong-nghe-cao.jpg',
        color: Colors.amber,
      ),
    ];
  }
}
