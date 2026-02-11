import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
import '../screens/blog/blog_list_screen.dart';
import '../screens/blog/blog_detail_screen.dart';
import '../screens/blog/create_blog_screen.dart';
import '../screens/blog/edit_blog_screen.dart';
import '../screens/blog/search_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == '/login' || location == '/register' || location == '/profile-setup';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main app routes with bottom nav
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const BlogListScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Detail and create routes (no bottom nav)
      GoRoute(
        path: '/blog/:id',
        name: 'blog-detail',
        builder: (context, state) {
          final blogId = state.pathParameters['id']!;
          return BlogDetailScreen(blogId: blogId);
        },
      ),
      GoRoute(
        path: '/create',
        name: 'create-blog',
        builder: (context, state) => const CreateBlogScreen(),
      ),
      GoRoute(
        path: '/edit/:id',
        name: 'edit-blog',
        builder: (context, state) {
          final blogId = state.pathParameters['id']!;
          return EditBlogScreen(blogId: blogId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
