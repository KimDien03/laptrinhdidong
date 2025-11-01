import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/auth_screen.dart';
import '../trip_planner/trip_planner_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final user = state.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Chưa đăng nhập',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'Tài khoản của tôi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 🧍‍♂️ Thông tin người dùng
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.teal.shade400,
                      child: Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (user.contactDisplay.isNotEmpty)
                            Text(
                              user.contactDisplay,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 🗺️ Kế hoạch chuyến đi
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.map_outlined,
                      color: Colors.teal, size: 30),
                  title: const Text(
                    'Kế hoạch chuyến đi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Đã tạo ${state.plans.length} lịch trình'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).pushNamed(TripPlannerScreen.routeName);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // 🕓 Lịch sử tìm kiếm
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading:
                      const Icon(Icons.history, color: Colors.teal, size: 30),
                  title: const Text(
                    'Lịch sử tìm kiếm',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    user.searchHistory.isEmpty
                        ? 'Chưa có lịch sử tìm kiếm'
                        : user.searchHistory.join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🛠️ Admin Dashboard
              if (user.isAdmin)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: Colors.teal, size: 30),
                    title: const Text(
                      'Bảng điều khiển Admin',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.teal),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(AdminDashboardScreen.routeName);
                    },
                  ),
                ),

              const SizedBox(height: 30),

              // 🚪 Đăng xuất
              FilledButton.icon(
                onPressed: () {
                  state.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AuthScreen.routeName,
                    (route) => false,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
