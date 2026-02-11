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

/// Top navigation bar for wide screens
class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final String title;
  final List<Widget>? actions;

  const TopNavBar({
    super.key,
    required this.currentIndex,
    this.title = 'Blog',
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = isWideScreen(context);

    return AppBar(
      title: Row(
        children: [
          // Logo / Brand
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.article_rounded,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          // Desktop nav links
          if (wide) ...[
            const SizedBox(width: 32),
            _NavLink(
              label: 'Home',
              icon: Icons.home_outlined,
              isActive: currentIndex == 0,
              onTap: () => context.go('/'),
            ),
            _NavLink(
              label: 'Search',
              icon: Icons.search,
              isActive: currentIndex == 1,
              onTap: () => context.go('/search'),
            ),
            _NavLink(
              label: 'Write',
              icon: Icons.edit_outlined,
              isActive: currentIndex == 2,
              onTap: () => context.go('/create'),
            ),
          ],
        ],
      ),
      centerTitle: false,
      elevation: 0,
      actions: [
        if (wide) ...[
          if (actions != null) ...actions!,
          const SizedBox(width: 8),
          _ProfileButton(
            isActive: currentIndex == 3,
            onTap: () => context.go('/profile'),
          ),
          const SizedBox(width: 16),
        ] else if (actions != null)
          ...actions!,
      ],
    );
  }
}

/// Single nav link for top bar
class _NavLink extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isActive
        ? theme.colorScheme.primary
        : _hovering
            ? theme.colorScheme.onSurface.withOpacity(0.8)
            : theme.colorScheme.onSurface.withOpacity(0.5);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.isActive
                ? theme.colorScheme.primary.withOpacity(0.08)
                : _hovering
                    ? theme.colorScheme.onSurface.withOpacity(0.04)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: color,
                  fontWeight:
                      widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get icon => widget.icon;
}

/// Profile avatar button for top bar
class _ProfileButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _ProfileButton({required this.isActive, required this.onTap});

  @override
  State<_ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<_ProfileButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;
    final initials = profile?.displayName?.isNotEmpty == true
        ? profile!.displayName[0].toUpperCase()
        : '?';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isActive
                  ? theme.colorScheme.primary
                  : _hovering
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : Colors.transparent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: profile?.avatarUrl?.isNotEmpty == true
                ? NetworkImage(profile!.avatarUrl)
                : null,
            child: profile?.avatarUrl?.isNotEmpty != true
                ? Text(
                    initials,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
