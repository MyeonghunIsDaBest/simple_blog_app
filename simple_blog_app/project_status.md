# Project Status
> Last updated: Session 2 - ALL PHASES COMPLETE

---

## Quick Summary
| Item | Status |
|------|--------|
| **Current Phase** | ALL 10 PHASES COMPLETE |
| **Next Task** | Supabase table setup + testing on device |
| **Blockers** | Need to create tables in Supabase (profiles, blogs, comments) |
| **App Runnable** | Yes - full app with auth, blog CRUD, profile, dark mode |

---

## Environment Setup

| Requirement | Status |
|-------------|--------|
| Flutter SDK | Installed |
| VS Code + Flutter Extension | Ready |
| Android Studio | Ready |
| Supabase Project | Using existing (from React app, same API key) |
| `.env` file | Configured |
| `flutter doctor` | Verified |
| `flutter pub get` | Dependencies installed |

---

## Implementation Progress

### Phase 0: Folder Structure
**Status: COMPLETE**

All folders and placeholder files created.

### Phase 1: App Theme Setup
**Status: COMPLETE**

**File:** `lib/config/app_theme.dart`

**What was built:**
- `AppTheme` class with static theme configurations
- `lightTheme` - Light mode ThemeData
- `darkTheme` - Dark mode ThemeData
- Configured: ColorScheme, AppBar, Cards, Buttons, TextFields, FAB, BottomNav, Dividers

**Key concepts learned:**
- ThemeData - container for all app styles
- ColorScheme - color palette with roles (primary, secondary, surface, error)
- Material 3 design system
- How to access theme: `Theme.of(context).colorScheme.primary`
- ThemeMode options: light, dark, system

**Colors used:**
- Primary: Indigo (#6366F1)
- Secondary: Purple (#8B5CF6)
- Error: Red (#EF4444)

### Phase 2: Data Models
**Status: COMPLETE**

**Files:**
- `lib/models/user_model.dart` - Auth user (id, email, createdAt)
- `lib/models/profile_model.dart` - User profile (username, bio, avatar)
- `lib/models/blog_model.dart` - Blog post (title, content, image, author)
- `lib/models/comment_model.dart` - Comment (content, blogId, author)

**What was built:**
- 4 model classes with fields, constructors, fromJson, toJson
- ProfileModel and BlogModel have copyWith() for immutable updates
- BlogModel and CommentModel handle joined profile data from Supabase

**Key concepts learned:**
- Models = blueprints for data (like TypeScript interfaces)
- `fromJson()` = turn API data into Dart objects
- `toJson()` = turn Dart objects into API data
- `copyWith()` = create a copy with changes (since fields are final)
- `required` vs optional (?) parameters

### Phase 3: Supabase Services
**Status: COMPLETE**

**Files:**
- `lib/services/auth_service.dart` - Authentication & profile operations
- `lib/services/blog_service.dart` - Blog & comment CRUD operations

**What was built:**
- AuthService: signUp, signIn, signOut, currentUser getter, onAuthStateChange stream
- AuthService: createProfile, getProfile, updateProfile (profiles table)
- BlogService: getBlogs, getBlogById, getUserBlogs (with joined profile data)
- BlogService: createBlog, updateBlog, deleteBlog
- BlogService: getComments, addComment, deleteComment

**Key concepts learned:**
- Service = middleman between app and database (like api.js in JavaScript)
- `Future` = Dart's version of JavaScript's `Promise` (fires once)
- `Stream` = like JavaScript's `addEventListener` (fires many times)
- Supabase queries in Dart look almost identical to JavaScript
- `.single()` = expect exactly one result, `.maybeSingle()` = might be null
- SELECT with joins: `select('*, profiles(username, avatar_url)')`

### Phase 4: State Management
**Status: COMPLETE**

**Files:**
- `lib/providers/auth_provider.dart` - Auth state (user, profile, login/logout)
- `lib/providers/blog_provider.dart` - Blog state (CRUD, comments)
- `lib/providers/theme_provider.dart` - Theme state (light/dark, persisted)

**What was built:**
- AuthProvider: initialize, signUp, signIn, signOut, updateProfile, auth stream listener
- BlogProvider: fetchBlogs, fetchUserBlogs, createBlog, updateBlog, deleteBlog, comments CRUD
- ThemeProvider: toggleTheme, setThemeMode, persists to SharedPreferences

**Key concepts learned:**
- ChangeNotifier = class that can notify widgets when data changes
- `notifyListeners()` = like calling setState() but for the WHOLE app
- `context.watch<T>()` = rebuilds widget when provider changes (for build method)
- `context.read<T>()` = one-time read, no rebuild (for callbacks/handlers)
- `..initialize()` = cascade operator, calls method on object and returns it

### Phase 5: Navigation
**Status: COMPLETE**

**File:** `lib/config/app_router.dart`

**What was built:**
- GoRouter with 8 routes: login, register, profile-setup, home, blog detail, create blog, edit blog, profile
- Route guard (redirect) that checks: is user logged in? has profile?
- `refreshListenable` auto-refreshes routes when auth state changes

**Key concepts learned:**
- `context.go('/path')` = replace current route (like React's `navigate`)
- `context.push('/path')` = add to navigation stack (like `history.push`)
- `context.pop()` = go back
- `redirect` = route guard, runs before every navigation
- Path parameters: `/blog/:id` → `state.pathParameters['id']`

### Phase 6: Auth Screens
**Status: COMPLETE**

**Files:**
- `lib/screens/auth/login_screen.dart` - Email/password login form
- `lib/screens/auth/register_screen.dart` - Registration with username, email, password
- `lib/screens/auth/profile_setup_screen.dart` - Profile setup after registration

**What was built:**
- Login form with email/password, validation, loading state, error display
- Register form with username, email, password, confirm password
- Profile setup with username, display name, bio fields
- Password visibility toggle, form validation

**Key concepts learned:**
- `TextEditingController` = holds text field value (like useRef in React)
- `GlobalKey<FormState>` = validates all form fields at once
- `TextFormField` + `validator` = built-in validation
- `obscureText` = hides password text
- `mounted` check = prevent setState after widget is disposed

### Phase 7: Blog Screens
**Status: COMPLETE**

**Files:**
- `lib/screens/blog/blog_list_screen.dart` - Home page with blog feed
- `lib/screens/blog/blog_detail_screen.dart` - Full blog view with comments
- `lib/screens/blog/create_blog_screen.dart` - Create new blog post
- `lib/screens/blog/edit_blog_screen.dart` - Edit existing blog post

**What was built:**
- Blog list with cards (title, content preview, author, date), pull-to-refresh, FAB
- Blog detail with full content, author info, comments section, edit/delete (if author)
- Create blog form with title, content, optional image URL
- Edit blog form pre-filled with existing data
- Theme toggle button in app bar, profile button

**Key concepts learned:**
- `ListView.builder` = efficiently renders lists (like React virtualized list)
- `RefreshIndicator` = pull-to-refresh widget
- `InkWell` = clickable area with Material ripple effect
- `CircleAvatar` = round avatar widget
- `showDialog` = display confirmation dialog
- `DateFormat` from `intl` = format dates (like moment.js)

### Phase 8: Profile Screen
**Status: COMPLETE**

**File:** `lib/screens/profile/profile_screen.dart`

**What was built:**
- Profile display (avatar, username, display name, bio, email)
- Inline edit mode (tap edit → fields appear → save/cancel)
- User's blog posts list
- Dark mode toggle switch
- Logout with confirmation dialog

**Key concepts learned:**
- Conditional UI rendering with bool flag (`_isEditing`)
- `ListTile` + `Switch` = settings-style toggle
- `showDialog` for confirmation before destructive actions

### Phase 9: Main App Integration
**Status: COMPLETE**

**File:** `lib/main.dart`

**What was built:**
- `WidgetsFlutterBinding.ensureInitialized()` for async startup
- `.env` loading with flutter_dotenv
- Supabase initialization
- `MultiProvider` wrapping 3 providers (Auth, Blog, Theme)
- `MaterialApp.router` with theme + router config
- Cascade operator `..initialize()` for provider setup

**Key concepts learned:**
- `WidgetsFlutterBinding.ensureInitialized()` = required before async in main()
- `MultiProvider` = wrap app with multiple global state providers
- `MaterialApp.router` = use GoRouter instead of Navigator
- `..` cascade operator = call method and still return the object
- Everything connects: main.dart → providers → router → screens → services → models

---

## File Status

### Config Files
| File | Status | Description |
|------|--------|-------------|
| `lib/config/app_theme.dart` | **COMPLETE** | Light/Dark theme configuration |
| `lib/config/app_router.dart` | **COMPLETE** | GoRouter with 8 routes + auth guard |

### Model Files
| File | Status | Description |
|------|--------|-------------|
| `lib/models/user_model.dart` | **COMPLETE** | Auth user data |
| `lib/models/profile_model.dart` | **COMPLETE** | User profile data |
| `lib/models/blog_model.dart` | **COMPLETE** | Blog post data |
| `lib/models/comment_model.dart` | **COMPLETE** | Comment data |

### Service Files
| File | Status | Description |
|------|--------|-------------|
| `lib/services/auth_service.dart` | **COMPLETE** | Supabase auth + profiles |
| `lib/services/blog_service.dart` | **COMPLETE** | Blog & comment CRUD |

### Provider Files
| File | Status | Description |
|------|--------|-------------|
| `lib/providers/auth_provider.dart` | **COMPLETE** | Auth state management |
| `lib/providers/blog_provider.dart` | **COMPLETE** | Blog state management |
| `lib/providers/theme_provider.dart` | **COMPLETE** | Theme state + persistence |

### Screen Files
| File | Status | Description |
|------|--------|-------------|
| `lib/screens/auth/login_screen.dart` | **COMPLETE** | Login form UI |
| `lib/screens/auth/register_screen.dart` | **COMPLETE** | Registration form UI |
| `lib/screens/auth/profile_setup_screen.dart` | **COMPLETE** | Profile setup UI |
| `lib/screens/blog/blog_list_screen.dart` | **COMPLETE** | Blog feed (home) |
| `lib/screens/blog/blog_detail_screen.dart` | **COMPLETE** | Blog + comments view |
| `lib/screens/blog/create_blog_screen.dart` | **COMPLETE** | Create blog form |
| `lib/screens/blog/edit_blog_screen.dart` | **COMPLETE** | Edit blog form |
| `lib/screens/profile/profile_screen.dart` | **COMPLETE** | User profile + settings |

### Entry Point
| File | Status | Description |
|------|--------|-------------|
| `lib/main.dart` | **COMPLETE** | App bootstrap with providers + router |

---

## Architecture Flow

```
main.dart (entry point)
  ├── Supabase.initialize()          → Connect to backend
  ├── MultiProvider                   → Global state
  │   ├── AuthProvider               → User auth state
  │   ├── BlogProvider               → Blog data state
  │   └── ThemeProvider              → Theme state
  └── MaterialApp.router             → App shell
      └── GoRouter (app_router.dart) → Navigation
          ├── /login                 → LoginScreen
          ├── /register              → RegisterScreen
          ├── /profile-setup         → ProfileSetupScreen
          ├── / (home)               → BlogListScreen
          ├── /blog/:id              → BlogDetailScreen
          ├── /create-blog           → CreateBlogScreen
          ├── /edit-blog/:id         → EditBlogScreen
          └── /profile               → ProfileScreen

Screens → use Providers → call Services → talk to Supabase → use Models
```

---

## What I Learned

### Phase 1: Theming
1. **Theme** = one place to define all your app's colors
2. **ThemeData** = the container (like CSS :root variables)
3. **ColorScheme** = color palette (primary, secondary, error, surface)
4. **Theme.of(context)** = access theme in any widget
5. **ThemeMode.system** = phone decides light/dark mode

### Phase 2: Data Models
1. **Model** = blueprint for data (like TypeScript interface)
2. **fromJson()** = API data → Dart object
3. **toJson()** = Dart object → API data
4. **copyWith()** = create copy with some changes
5. **required** = must provide, **?** = optional/nullable

### Phase 3: Supabase Services
1. **Service** = middleman between app and database (like api.js)
2. **Future** = Dart's Promise (fires once, returns data)
3. **Stream** = like addEventListener (fires many times)
4. **Supabase Dart queries** = almost identical to JavaScript Supabase queries
5. **`.single()`** = expect one result, **`.maybeSingle()`** = might be null
6. **SELECT with join** = `select('*, profiles(username)')` gets related data

### Phase 4: State Management
1. **ChangeNotifier** = class that can broadcast changes
2. **notifyListeners()** = tell all watching widgets to rebuild
3. **context.watch()** = subscribe to changes (use in build)
4. **context.read()** = one-time read (use in callbacks)
5. **Provider pattern** = Service does the work, Provider holds the state

### Phase 5: Navigation
1. **GoRouter** = declarative routing (like React Router)
2. **context.go()** = replace route, **context.push()** = add to stack
3. **redirect** = route guard for auth checks
4. **Path params** = `/blog/:id` → `state.pathParameters['id']`
5. **refreshListenable** = auto-refresh routes when state changes

### Phase 6-8: Screens
1. **TextEditingController** = holds form field value (like useRef)
2. **Form + GlobalKey** = validates all fields at once
3. **ListView.builder** = efficient scrollable list
4. **RefreshIndicator** = pull-to-refresh
5. **showDialog** = confirmation popups
6. **mounted** = check if widget is still alive before setState

### Phase 9: Main Integration
1. **WidgetsFlutterBinding.ensureInitialized()** = required for async main
2. **MultiProvider** = multiple global state containers
3. **MaterialApp.router** = app shell with GoRouter
4. **`..` cascade** = call method and return object
5. **Everything connects:** main → providers → router → screens → services → models

---

## Before Testing: Supabase Table Setup Required

Create these tables in your Supabase dashboard:

### profiles table
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key, references auth.users(id) |
| username | text | Unique, not null |
| display_name | text | Nullable |
| bio | text | Nullable |
| avatar_url | text | Nullable |
| created_at | timestamptz | Default: now() |
| updated_at | timestamptz | Default: now() |

### blogs table
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key, default: gen_random_uuid() |
| title | text | Not null |
| content | text | Not null |
| image_url | text | Nullable |
| author_id | uuid | References auth.users(id), not null |
| created_at | timestamptz | Default: now() |
| updated_at | timestamptz | Default: now() |

### comments table
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key, default: gen_random_uuid() |
| content | text | Not null |
| blog_id | uuid | References blogs(id), not null |
| author_id | uuid | References auth.users(id), not null |
| created_at | timestamptz | Default: now() |

**Note:** Enable RLS (Row Level Security) on all tables!
