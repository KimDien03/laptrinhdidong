import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ====== Firebase: thêm 2 import này ======
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// ========================================
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app_state.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/explore/explore_shell.dart';
import 'screens/place_detail/place_detail_screen.dart';
import 'screens/trip_planner/trip_planner_screen.dart';
import 'services/location_service.dart';
import 'services/mock_data_service.dart';
import 'services/recommendation_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'config/mapbox_config.dart';

// ====== Khởi tạo Firebase trước khi runApp ======
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      MapboxOptions.setAccessToken(mapboxAccessToken);
    } catch (error, stackTrace) {
      debugPrint('Failed to set Mapbox access token: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FoodTravelApp());
}
// ================================================

class FoodTravelApp extends StatelessWidget {
  const FoodTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(
        dataService: MockDataService(),
        locationService: LocationService(),
        storageService: StorageService(),
        recommendationService: RecommendationService(),
        firestoreService: FirestoreService(),
      )..initialize(),
      child: MaterialApp(
        title: 'Food Travel',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        // Giữ cơ chế bootstrap như cũ
        routes: {
          '/': (_) => const AppBootstrapper(),
          AuthScreen.routeName: (_) =>
              const AuthScreen(), // Màn hình Auth (đăng ký/đăng nhập)
          ExploreShell.routeName: (_) => const ExploreShell(),
          PlaceDetailScreen.routeName: (_) => const PlaceDetailScreen(),
          TripPlannerScreen.routeName: (_) => const TripPlannerScreen(),
          AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}

class AppBootstrapper extends StatelessWidget {
  const AppBootstrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nếu chưa đăng nhập, điều hướng tới Auth
        if (state.currentUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
          });
          return const SizedBox.shrink();
        }

        // Đã đăng nhập -> vào Explore
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(ExploreShell.routeName);
        });
        return const SizedBox.shrink();
      },
    );
  }
}






