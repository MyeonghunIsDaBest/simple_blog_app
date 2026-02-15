// lib/widgets/sidebar_nav.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'responsive_layout.dart';

class SidebarNav extends StatelessWidget {
  final int currentIndex;

  const SidebarNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expanded = isSidebarExpanded(context);
    final width =
        expanded ? AppBreakpoints.sidebarExpanded : AppBreakpoints.sidebarCollapsed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: theme.dividerTheme.color ?? Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Brand logo
          _BrandLogo(expanded: expanded),

          const SizedBox(height: 32),

          // Nav items
          _SidebarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            isActive: currentIndex == 0,
            expanded: expanded,
            onTap: () => context.go('/'),
          ),
          _SidebarItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search_rounded,
            label: 'Search',
            isActive: currentIndex == 1,
            expanded: expanded,
            onTap: () => context.go('/search'),
          ),
          _SidebarItem(
            icon: Icons.edit_outlined,
            activeIcon: Icons.edit_rounded,
            label: 'Write',
            isActive: currentIndex == 2,
            expanded: expanded,
            onTap: () => context.go('/create'),
          ),

          const Spacer(),

          // Theme toggle
          _ThemeToggleItem(expanded: expanded),

          const SizedBox(height: 4),

          // Profile
          _SidebarProfileItem(
            isActive: currentIndex == 3,
            expanded: expanded,
            onTap: () => context.go('/profile'),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  final bool expanded;

  const _BrandLogo({required this.expanded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: expanded ? 20 : 0),
      child: expanded
          ? Row(
              children: [
                _buildIcon(theme),
                const SizedBox(width: 12),
                Text(
                  'Blog',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            )
          : Center(child: _buildIcon(theme)),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.article_rounded, size: 20, color: Colors.white),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool expanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.expanded,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isActive
        ? theme.colorScheme.primary
        : _hovering
            ? theme.colorScheme.onSurface.withOpacity(0.85)
            : theme.colorScheme.onSurface.withOpacity(0.55);

    final bg = widget.isActive
        ? theme.colorScheme.primary.withOpacity(0.1)
        : _hovering
            ? theme.colorScheme.onSurface.withOpacity(0.04)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            horizontal: widget.expanded ? 12 : 14,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.expanded ? 16 : 0,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.expanded
              ? Row(
                  children: [
                    Icon(
                      widget.isActive ? widget.activeIcon : widget.icon,
                      size: 22,
                      color: color,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight:
                            widget.isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    widget.isActive ? widget.activeIcon : widget.icon,
                    size: 24,
                    color: color,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ThemeToggleItem extends StatefulWidget {
  final bool expanded;

  const _ThemeToggleItem({required this.expanded});

  @override
  State<_ThemeToggleItem> createState() => _ThemeToggleItemState();
}

class _ThemeToggleItemState extends State<_ThemeToggleItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final color = _hovering
        ? theme.colorScheme.onSurface.withOpacity(0.85)
        : theme.colorScheme.onSurface.withOpacity(0.55);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => themeProvider.toggleTheme(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            horizontal: widget.expanded ? 12 : 14,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.expanded ? 16 : 0,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: _hovering
                ? theme.colorScheme.onSurface.withOpacity(0.04)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.expanded
              ? Row(
                  children: [
                    Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      size: 22,
                      color: color,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isDark ? 'Light mode' : 'Dark mode',
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: 24,
                    color: color,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SidebarProfileItem extends StatefulWidget {
  final bool isActive;
  final bool expanded;
  final VoidCallback onTap;

  const _SidebarProfileItem({
    required this.isActive,
    required this.expanded,
    required this.onTap,
  });

  @override
  State<_SidebarProfileItem> createState() => _SidebarProfileItemState();
}

class _SidebarProfileItemState extends State<_SidebarProfileItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final initials = profile?.initials ?? '?';
    final color = widget.isActive
        ? theme.colorScheme.primary
        : _hovering
            ? theme.colorScheme.onSurface.withOpacity(0.85)
            : theme.colorScheme.onSurface.withOpacity(0.55);
    final bg = widget.isActive
        ? theme.colorScheme.primary.withOpacity(0.1)
        : _hovering
            ? theme.colorScheme.onSurface.withOpacity(0.04)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            horizontal: widget.expanded ? 12 : 14,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.expanded ? 12 : 0,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.expanded
              ? Row(
                  children: [
                    _buildAvatar(theme, profile, initials),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.nameOrEmail ?? 'Profile',
                            style: TextStyle(
                              color: color,
                              fontSize: 14,
                              fontWeight: widget.isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (profile?.email != null)
                            Text(
                              profile!.email,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(child: _buildAvatar(theme, profile, initials)),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, dynamic profile, String initials) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(2),
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
        radius: 16,
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
    );
  }
}
