import 'package:flutter/material.dart';

import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'explore_tab.dart';

class ExploreShell extends StatefulWidget {
  const ExploreShell({super.key});

  static const String routeName = '/explore';

  @override
  State<ExploreShell> createState() => _ExploreShellState();
}

class _ExploreShellState extends State<ExploreShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ExploreTab(),
    SearchScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: NavigationBar(
            height: 65,
            backgroundColor: colorScheme.surface,
            indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.35),
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: 'Khám phá',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Tìm kiếm',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: 'Yêu thích',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
