// lib/widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'responsive_layout.dart';

/// Adaptive navigation:
/// - Mobile → Bottom nav bar
/// - Desktop → Hidden (top nav is in AppBar via AdaptiveScaffold)
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/create');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide bottom nav on wide screens (top nav handles it)
    if (isWideScreen(context)) {
      return const SizedBox.shrink();
    }

    return _buildBottomNav(context);
  }

  Widget _buildBottomNav(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final userInitials = _getUserInitials(profile, authProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onNavTap(context, index),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: CircleAvatar(
            radius: 12,
            backgroundColor: currentIndex == 3
                ? Theme.of(context).primaryColor
                : Colors.grey,
            child: Text(
              userInitials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  String _getUserInitials(dynamic profile, AuthProvider authProvider) {
    if (profile?.displayName?.isNotEmpty == true) {
      return profile!.displayName
          .split(' ')
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
          .join();
    }
    return profile?.email?.split('@').first.substring(0, 1).toUpperCase() ??
        '?';
  }
}
