# simple_blog_app

lib tree 

flutter_blog/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   ├── app_router.dart          # Navigation with go_router
│   │   └── app_theme.dart           # Light/Dark theme config
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── profile_model.dart
│   │   ├── blog_model.dart
│   │   └── comment_model.dart
│   ├── services/
│   │   ├── auth_service.dart        # Supabase auth
│   │   └── blog_service.dart        # CRUD operations
│   ├── providers/
│   │   ├── auth_provider.dart       # Auth state
│   │   ├── blog_provider.dart       # Blog state
│   │   └── theme_provider.dart      # Theme state
│   └── screens/
│       ├── auth/
│       │   ├── login_screen.dart
│       │   ├── register_screen.dart
│       │   └── profile_setup_screen.dart
│       ├── blog/
│       │   ├── blog_list_screen.dart
│       │   ├── blog_detail_screen.dart
│       │   ├── create_blog_screen.dart
│       │   └── edit_blog_screen.dart
│       └── profile/
│           └── profile_screen.dart
├── pubspec.yaml                      # Dependencies
└── .env                              # Your Supabase credentials