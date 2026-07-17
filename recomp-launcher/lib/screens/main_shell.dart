import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'import_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    LibraryScreen(),
    ImportScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        height: 64,
        animationDuration: const Duration(milliseconds: 300),
        destinations: [
          _navItem(icon: Icons.home_outlined, selected: Icons.home_rounded, label: 'Home', index: 0, current: currentIndex),
          _navItem(icon: Icons.grid_view_outlined, selected: Icons.grid_view_rounded, label: 'Library', index: 1, current: currentIndex),
          _navItem(icon: Icons.add_circle_outline_rounded, selected: Icons.add_circle_rounded, label: 'Import', index: 2, current: currentIndex),
          _navItem(icon: Icons.settings_outlined, selected: Icons.settings_rounded, label: 'Settings', index: 3, current: currentIndex),
        ],
      ),
    );
  }

  NavigationDestination _navItem({
    required IconData icon,
    required IconData selected,
    required String label,
    required int index,
    required int current,
  }) {
    final isSelected = index == current;
    return NavigationDestination(
      icon: Icon(icon).animate(target: isSelected ? 1 : 0).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.15, 1.15),
            duration: 200.ms,
            curve: Curves.easeOut,
          ),
      selectedIcon: Icon(selected),
      label: label,
    );
  }
}
