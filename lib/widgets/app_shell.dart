// lib/widgets/app_shell.dart

import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'sidebar_nav.dart';
import 'responsive_layout.dart';

class AppShell extends StatelessWidget {
  final int currentIndex;
  final Widget body;

  const AppShell({
    super.key,
    required this.currentIndex,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final hasSidebar = showSidebar(context);

    return Scaffold(
      appBar: hasSidebar ? null : _buildMobileAppBar(context),
      bottomNavigationBar:
          hasSidebar ? null : BottomNavBar(currentIndex: currentIndex),
      body: Row(
        children: [
          if (hasSidebar) SidebarNav(currentIndex: currentIndex),
          Expanded(child: body),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
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
            'Blog',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      centerTitle: false,
      elevation: 0,
    );
  }
}
