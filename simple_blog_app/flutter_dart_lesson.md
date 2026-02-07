# Flutter & Dart Technical Guide for Job Interviews

> Personal study notes - not for version control

---

## Module 1: Dart Programming Language

### Overview
Dart is a **client-optimized**, **object-oriented** language developed by Google. It's designed for building fast apps on any platform with a focus on UI development.

### Key Technical Characteristics

| Feature | Description |
|---------|-------------|
| **Type System** | Sound null safety with static type checking; supports type inference via `var` |
| **Compilation** | AOT (Ahead-of-Time) for production, JIT (Just-in-Time) for development |
| **Concurrency** | Single-threaded with event loop; uses `Isolates` for parallel execution |
| **Memory** | Garbage collected with generational GC optimized for UI workloads |

### Null Safety
Dart enforces **sound null safety** - variables are non-nullable by default:

```dart
String name = 'John';      // Cannot be null
String? nickname;          // Nullable - can be null
nickname?.length;          // Null-aware access
nickname ?? 'Anonymous';   // Null coalescing
nickname!;                 // Null assertion (throws if null)
```

### Asynchronous Programming
Dart uses a **single-threaded event loop** model with Futures and Streams:

```dart
// Future - single async value
Future<User> fetchUser() async {
  final response = await http.get('/api/user');
  return User.fromJson(response.body);
}

// Stream - sequence of async values (real-time updates)
Stream<List<Post>> watchPosts() {
  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .map((data) => data.map(Post.fromJson).toList());
}

// Stream subscription
final subscription = watchPosts().listen((posts) {
  updateUI(posts);
});
subscription.cancel(); // Clean up
```

### Isolates (True Parallelism)
For CPU-intensive tasks, Dart uses **Isolates** - independent workers with their own memory:

```dart
// Offload heavy computation to an isolate
final result = await Isolate.run(() {
  return computeExpensiveOperation(largeDataSet);
});
```

---

## Module 2: Flutter Framework Architecture

### Architectural Layers

```
┌────────────────────────────────────────────────────┐
│                  Your Application                  │
│         (Widgets, State Management, Logic)         │
├────────────────────────────────────────────────────┤
│              Flutter Framework (Dart)              │
│  Material | Cupertino | Widgets | Rendering | etc  │
├────────────────────────────────────────────────────┤
│               Flutter Engine (C++)                 │
│      Skia (2D Graphics) | Dart Runtime | Text      │
├────────────────────────────────────────────────────┤
│                 Embedder (Platform)                │
│     Handles input, surface rendering, threading    │
└────────────────────────────────────────────────────┘
```

### Why Flutter Renders Its Own UI
Flutter uses **Skia graphics engine** to draw every pixel directly to a canvas. This differs from React Native which bridges to native components.

**Implications:**
- Pixel-perfect consistency across platforms
- No platform UI version inconsistencies
- Larger app size (~5-10MB overhead)
- Full control over rendering pipeline

### The Three Trees
Flutter maintains three parallel tree structures:

| Tree | Purpose |
|------|---------|
| **Widget Tree** | Immutable configuration/blueprint (what you write) |
| **Element Tree** | Mutable instances that manage widget lifecycle |
| **RenderObject Tree** | Handles layout, painting, and hit testing |

```dart
// Widget (immutable blueprint)
Container(
  width: 100,
  child: Text('Hello'),
)

// When you call setState(), Flutter:
// 1. Rebuilds Widget tree (cheap - just Dart objects)
// 2. Diffs against Element tree
// 3. Updates only changed RenderObjects (expensive)
```

---

## Module 3: Widget System

### StatelessWidget vs StatefulWidget

| Aspect | StatelessWidget | StatefulWidget |
|--------|-----------------|----------------|
| **State** | Immutable; rebuilt with new data from parent | Mutable internal state via `State` object |
| **Lifecycle** | `build()` only | `initState()`, `didChangeDependencies()`, `build()`, `dispose()` |
| **Use Case** | Pure UI based on inputs | Interactive components, animations, data fetching |
| **Performance** | Slightly more efficient | State object persists across rebuilds |

### StatefulWidget Lifecycle

```dart
class BlogEditor extends StatefulWidget {
  final String postId;
  const BlogEditor({required this.postId});

  @override
  State<BlogEditor> createState() => _BlogEditorState();
}

class _BlogEditorState extends State<BlogEditor> {
  late TextEditingController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Called once when State is created
    _controller = TextEditingController();
    _loadPost();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Called when dependencies (e.g., InheritedWidget) change
  }

  @override
  void didUpdateWidget(BlogEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Called when parent rebuilds with new widget
    if (oldWidget.postId != widget.postId) {
      _loadPost(); // Reload if postId changed
    }
  }

  @override
  void dispose() {
    // Called when State is permanently removed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Called on every rebuild (setState, parent rebuild, etc.)
    if (_isLoading) return CircularProgressIndicator();
    return TextField(controller: _controller);
  }
}
```

### Keys and Widget Identity
Flutter uses **keys** to preserve state when widgets move in a list:

```dart
// Without key - state gets mixed up when reordering
ListView(children: posts.map((p) => PostCard(post: p)).toList())

// With key - state follows the widget
ListView(children: posts.map((p) => PostCard(key: ValueKey(p.id), post: p)).toList())
```

**Key Types:**
- `ValueKey<T>` - based on a value (ID, string)
- `ObjectKey` - based on object identity
- `UniqueKey` - always unique (forces rebuild)
- `GlobalKey` - access state/widget from anywhere (use sparingly)

---

## Module 4: State Management with Provider

### Provider Pattern
Provider is a **dependency injection** and **state management** wrapper around `InheritedWidget`.

### Architecture

```dart
// 1. Define your state model
class BlogState extends ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  // Getters expose immutable view
  List<Post> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _repository.getPosts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(Post post) async {
    await _repository.create(post);
    _posts = [..._posts, post];
    notifyListeners();
  }
}
```

### Provider Setup & Consumption

```dart
// 2. Provide at app root (or appropriate scope)
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => BlogState()),
      ],
      child: MyApp(),
    ),
  );
}

// 3. Consume in widgets
class PostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Rebuilds when BlogState changes
    final blogState = context.watch<BlogState>();

    // Read without subscribing (won't rebuild)
    final auth = context.read<AuthState>();

    // Select specific value (rebuilds only when that value changes)
    final postCount = context.select<BlogState, int>((s) => s.posts.length);

    if (blogState.isLoading) {
      return SpinKitCircle(color: Colors.blue);
    }

    return ListView.builder(
      itemCount: blogState.posts.length,
      itemBuilder: (_, i) => PostCard(post: blogState.posts[i]),
    );
  }
}
```

### Consumer Widget (Scoped Rebuilds)

```dart
// Only rebuilds the specific part that needs BlogState
Scaffold(
  appBar: AppBar(title: Text('Blog')), // Never rebuilds for state changes
  body: Consumer<BlogState>(
    builder: (context, state, child) {
      return ListView(...); // Only this rebuilds
    },
  ),
);
```

---

## Module 5: Navigation with go_router

### Declarative Routing
go_router uses **declarative routing** - routes are defined as data, not imperatively pushed.

```dart
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthState>().isAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isLoggedIn && !isAuthRoute) return '/auth/login';
    if (isLoggedIn && isAuthRoute) return '/';
    return null; // No redirect
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(
          path: 'post/:id',
          builder: (context, state) {
            final postId = state.pathParameters['id']!;
            final showComments = state.uri.queryParameters['comments'] == 'true';
            return PostDetailScreen(postId: postId, showComments: showComments);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => LoginScreen(),
    ),
  ],
  errorBuilder: (context, state) => NotFoundScreen(),
);

// Usage
context.go('/post/123?comments=true');  // Navigate (replaces stack)
context.push('/post/123');               // Push onto stack
context.pop();                           // Go back
```

### ShellRoute (Nested Navigation)
For persistent UI elements like bottom navigation:

```dart
ShellRoute(
  builder: (context, state, child) {
    return Scaffold(
      body: child, // Nested route content
      bottomNavigationBar: BottomNavBar(),
    );
  },
  routes: [
    GoRoute(path: '/feed', builder: ...),
    GoRoute(path: '/search', builder: ...),
    GoRoute(path: '/profile', builder: ...),
  ],
)
```

---

## Module 6: Supabase Integration

### Setup

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(MyApp());
}

final supabase = Supabase.instance.client;
```

### CRUD Operations

```dart
class PostRepository {
  // CREATE
  Future<Post> createPost(Post post) async {
    final response = await supabase
        .from('posts')
        .insert(post.toJson())
        .select()
        .single();
    return Post.fromJson(response);
  }

  // READ
  Future<List<Post>> getPosts({int limit = 20, int offset = 0}) async {
    final response = await supabase
        .from('posts')
        .select('*, author:profiles(*), comments(count)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map(Post.fromJson).toList();
  }

  // UPDATE
  Future<void> updatePost(String id, Map<String, dynamic> updates) async {
    await supabase
        .from('posts')
        .update(updates)
        .eq('id', id);
  }

  // DELETE
  Future<void> deletePost(String id) async {
    await supabase
        .from('posts')
        .delete()
        .eq('id', id);
  }

  // REAL-TIME SUBSCRIPTION
  Stream<List<Post>> watchPosts() {
    return supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map(Post.fromJson).toList());
  }
}
```

### Authentication

```dart
class AuthRepository {
  // Sign up
  Future<AuthResponse> signUp(String email, String password) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign in
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Auth state stream
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  // Current user
  User? get currentUser => supabase.auth.currentUser;
}
```

### Storage (Image Upload)

```dart
Future<String> uploadImage(File file) async {
  final userId = supabase.auth.currentUser!.id;
  final fileName = '${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  // Compress image first
  final compressed = await FlutterImageCompress.compressWithFile(
    file.path,
    quality: 70,
    minWidth: 1024,
  );

  await supabase.storage
      .from('post-images')
      .uploadBinary(fileName, compressed!);

  return supabase.storage.from('post-images').getPublicUrl(fileName);
}
```

---

## Module 7: Common Interview Questions

### Q: Explain Flutter's rendering pipeline.
> "Flutter uses a three-tree architecture: Widget, Element, and RenderObject trees. When `setState()` is called, Flutter rebuilds the Widget tree (cheap Dart objects), diffs it against the Element tree to identify changes, and only updates affected RenderObjects which handle actual layout and painting. This optimization is why Flutter achieves 60fps performance."

### Q: What's the difference between `const` and `final`?
> "`final` variables are set once at runtime and can hold computed values. `const` are compile-time constants - the value must be determinable during compilation. `const` constructors create canonicalized instances, meaning identical `const` objects share memory."

```dart
final now = DateTime.now();     // OK - computed at runtime
const now = DateTime.now();     // ERROR - not compile-time constant

const list1 = [1, 2, 3];
const list2 = [1, 2, 3];
print(identical(list1, list2)); // true - same instance
```

### Q: How does Flutter achieve cross-platform consistency?
> "Flutter doesn't use platform UI components. It ships its own rendering engine (Skia) and draws every pixel directly to a canvas provided by the platform's embedder. This means a Flutter button looks identical on iOS, Android, and web - there's no translation layer or platform bridging."

### Q: Explain `BuildContext`.
> "BuildContext is a handle to the location of a widget in the Element tree. It's used to walk up the tree and find ancestor widgets (via `context.findAncestorWidgetOfExactType`) or access inherited data (like Theme, MediaQuery, or Provider). Each widget's build method receives its own context."

### Q: What are Slivers?
> "Slivers are scrollable areas that implement lazy-loading and can produce variable-height content. `CustomScrollView` composes multiple slivers - like `SliverAppBar` (collapsing header), `SliverList` (lazy list), and `SliverGrid`. They're more flexible than `ListView` for complex scrolling layouts."

### Q: How would you optimize a slow ListView?
> "Several strategies: Use `ListView.builder` for lazy construction. Add `const` constructors to child widgets. Use `itemExtent` if items have fixed height. For complex items, use `RepaintBoundary` to isolate repaints. Consider `CachedNetworkImage` for images. Profile with DevTools to identify actual bottlenecks."

### Q: Explain Provider vs Riverpod vs Bloc.
> "Provider uses InheritedWidget for DI and ChangeNotifier for reactivity - simple but requires careful scope management. Riverpod is Provider's evolution - compile-safe, supports async natively, and allows providers outside the widget tree. Bloc enforces unidirectional data flow with Events and States - more boilerplate but highly testable and predictable."

---

## Module 8: Project Architecture Patterns

### Feature-First Structure
```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/        # Shared widgets
├── features/
│   ├── auth/
│   │   ├── data/       # Repository, data sources
│   │   ├── domain/     # Models, interfaces
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   └── blog/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── routing/
│   └── router.dart
└── main.dart
```

### Repository Pattern

```dart
// Abstract interface
abstract class PostRepository {
  Future<List<Post>> getPosts();
  Future<Post> getPost(String id);
  Future<void> createPost(Post post);
  Stream<List<Post>> watchPosts();
}

// Supabase implementation
class SupabasePostRepository implements PostRepository {
  final SupabaseClient _client;

  SupabasePostRepository(this._client);

  @override
  Future<List<Post>> getPosts() async {
    final response = await _client.from('posts').select();
    return response.map(Post.fromJson).toList();
  }
  // ... other methods
}

// Easy to swap for testing
class MockPostRepository implements PostRepository {
  @override
  Future<List<Post>> getPosts() async => [Post.mock()];
}
```

---

## Module 9: Dart Syntax Reference

### Null Safety Operators
```dart
String? name;
name?.length          // null if name is null
name ?? 'default'     // 'default' if name is null
name ??= 'fallback'   // assign if null
name!                 // assert non-null (throws if null)
```

### Collection Operations
```dart
final posts = [post1, post2, post3];

// Transform
posts.map((p) => p.title).toList();

// Filter
posts.where((p) => p.isPublished).toList();

// Find
posts.firstWhere((p) => p.id == '123', orElse: () => Post.empty());

// Aggregate
posts.fold<int>(0, (sum, p) => sum + p.likes);

// Spread & collection-if/for
final allPosts = [
  ...pinnedPosts,
  if (showDrafts) ...drafts,
  for (var tag in tags) Post.forTag(tag),
];
```

### Extension Methods
```dart
extension StringX on String {
  String get capitalized => '${this[0].toUpperCase()}${substring(1)}';
  bool get isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
}

// Usage
'hello'.capitalized;          // 'Hello'
'test@email.com'.isValidEmail; // true
```

### Pattern Matching (Dart 3)
```dart
// Switch expressions
String describePost(Post post) => switch (post) {
  Post(isPublished: true, likes: > 100) => 'Viral post',
  Post(isPublished: true) => 'Published',
  Post(isDraft: true) => 'Draft',
  _ => 'Unknown',
};

// Destructuring
final Post(:title, :author) = post;
print('$title by $author');
```

---

## Module 10: Performance Best Practices

| Practice | Reason |
|----------|--------|
| Use `const` constructors | Prevents unnecessary rebuilds; widgets are cached |
| `ListView.builder` over `ListView` | Lazy construction; only builds visible items |
| `context.select()` over `context.watch()` | Rebuilds only when selected value changes |
| `RepaintBoundary` | Isolates repaint regions for complex widgets |
| `CachedNetworkImage` | Caches images to disk/memory |
| Avoid `setState()` in build | Causes infinite rebuild loops |
| Use `ValueListenableBuilder` | Fine-grained rebuilds for single values |

---

## Quick Reference Card

| Concept | One-Liner |
|---------|-----------|
| **Widget** | Immutable configuration describing UI |
| **Element** | Mutable instance managing widget lifecycle |
| **RenderObject** | Handles layout, painting, hit testing |
| **BuildContext** | Handle to Element's location in tree |
| **InheritedWidget** | Efficiently propagates data down the tree |
| **Future** | Single async value |
| **Stream** | Sequence of async values over time |
| **Isolate** | Independent thread with separate memory |
| **AOT** | Ahead-of-Time compilation for production |
| **JIT** | Just-in-Time compilation for hot reload |

---

## Module 11: Assessment-Specific Interview Preparation

### Decoding the Assessment Statement

> "Flutter Assessment - Blog: **Learn and understand** Flutter, **know its language**, **its concept** and **know how to set up** flutter. Using the **same Supabase database** create a Blog using flutter with the following conditions:"

The interviewer structured this assessment around **5 pillars**. They will probe each one:

| Pillar | What They'll Probe | Depth Expected |
|--------|-------------------|----------------|
| **"Learn and understand"** | Can you explain WHY, not just WHAT | Conceptual understanding, not memorization |
| **"Know its language"** | Dart-specific features distinct from JS/TS | Null safety, type system, async model, classes |
| **"Its concept"** | Flutter's unique architecture | Widget tree, rendering pipeline, state management |
| **"Know how to set up"** | Full development workflow | CLI commands, project structure, dependencies, env config |
| **"Same Supabase database"** | Cross-platform backend integration | Client differences, shared schema, auth flow |

---

### Category 1: Flutter Setup & Development Workflow

**Q: Walk me through creating a Flutter project from zero.**

> "First, ensure Flutter SDK is installed and on PATH. Run `flutter doctor` to verify the toolchain - it checks the SDK, Android Studio, Xcode (for iOS), and connected devices.
>
> Create the project with `flutter create my_app`. This scaffolds the directory structure including `lib/` for Dart code, `android/` and `ios/` for platform-specific config, `pubspec.yaml` for dependencies, and `test/` for unit tests.
>
> Add dependencies in `pubspec.yaml` under `dependencies:` and run `flutter pub get`. For environment variables, I use `flutter_dotenv` with a `.env` file added to the assets section. For Supabase, I call `Supabase.initialize()` in `main()` before `runApp()`.
>
> During development, `flutter run` launches the app with JIT compilation, enabling hot reload (`r`) for instant UI updates and hot restart (`R`) for full state reset. For production, `flutter build apk` (Android) or `flutter build ipa` (iOS) uses AOT compilation for native performance."

**Q: What's the difference between `flutter run`, `flutter build`, and `flutter analyze`?**

> - `flutter run` - Launches the app in debug mode with JIT compilation. Supports hot reload.
> - `flutter build apk/ipa` - Compiles to a production binary with AOT compilation. No hot reload, but optimized for performance and smaller size.
> - `flutter analyze` - Static analysis tool that checks for lint errors, type issues, and style violations without running the app. Uses rules from `analysis_options.yaml`.

**Q: Explain `pubspec.yaml` vs `pubspec.lock`.**

> "`pubspec.yaml` is what I write - it declares dependencies with version ranges like `supabase_flutter: ^1.10.25` (meaning 1.10.25 or higher within major version 1). `pubspec.lock` is auto-generated and pins the exact resolved versions (like `1.10.25` specifically). I commit both to git so team members get identical dependency versions."

**Q: What does `WidgetsFlutterBinding.ensureInitialized()` do?**

> "It initializes Flutter's binding between the framework and the engine. It's required before calling any async operations in `main()` - like loading `.env` files or initializing Supabase. Without it, the engine hasn't set up the event loop yet, so async calls would fail."

---

### Category 2: Dart Language Deep Dives

**Q: Explain Dart's sound null safety. Why is it better than TypeScript's?**

> "Dart's null safety is 'sound' - meaning if a type says it's non-nullable, the compiler GUARANTEES it's never null at runtime. TypeScript's null checking is unsound - you can bypass it with `any` type, type assertions, or unchecked index access.
>
> In practice: `String name` in Dart will NEVER be null. The compiler tracks every code path to ensure it's assigned before use. `String? name` explicitly opts into nullability, forcing you to handle the null case with `?.`, `??`, or `!`.
>
> In my blog app: `BlogModel.title` is `String` (always present), but `BlogModel.imageUrl` is `String?` because a blog post might not have an image."

**Q: What are named parameters and why does Flutter use them everywhere?**

> "Named parameters are arguments passed by name rather than position. Flutter uses them because widgets often have 10+ properties, and positional arguments would be unreadable:
>
> ```dart
> // Positional (unreadable)
> Container(100, 50, Colors.blue, EdgeInsets.all(8), 'text');
>
> // Named (clear)
> Container(width: 100, height: 50, color: Colors.blue, padding: EdgeInsets.all(8));
> ```
>
> `required` means the parameter must be provided. Without `required`, it's optional and defaults to null (if nullable) or a default value."

**Q: Explain the `factory` keyword in constructors.**

> "A `factory` constructor can return an existing instance or a different subtype, unlike regular constructors which always create a new instance. I use `factory` for `fromJson` methods because the constructor needs to process the JSON data before creating the object:
>
> ```dart
> factory BlogModel.fromJson(Map<String, dynamic> json) {
>   return BlogModel(
>     id: json['id'],
>     title: json['title'],
>     authorProfile: json['profiles'] != null
>         ? ProfileModel.fromJson(json['profiles'])
>         : null,  // Process nested data
>   );
> }
> ```
> The factory does transformation work that a regular constructor can't."

**Q: What's the `late` keyword?**

> "`late` tells Dart 'I promise this variable will be initialized before I use it, but I can't initialize it right now.' It's used when you need a non-nullable field that depends on something not available at construction time:
>
> ```dart
> late TextEditingController _controller;
>
> @override
> void initState() {
>   super.initState();
>   _controller = TextEditingController(text: widget.initialValue);
> }
> ```
> Without `late`, you'd have to make it nullable (`TextEditingController?`) and add null checks everywhere."

---

### Category 3: Flutter Architecture & Concepts

**Q: Explain Flutter's three-tree architecture.**

> "Flutter maintains three parallel trees:
>
> 1. **Widget Tree** - The blueprint. Immutable Dart objects describing the UI. Cheap to create and destroy. This is what I write in `build()` methods.
>
> 2. **Element Tree** - The manager. Mutable objects that hold the actual widget lifecycle. When I call `setState()`, Flutter compares the new Widget tree against the Element tree to find what changed.
>
> 3. **RenderObject Tree** - The painter. Handles layout (measuring sizes), painting (drawing pixels), and hit testing (touch detection). Only updated when Elements detect actual changes.
>
> This is why Flutter is fast: rebuilding the Widget tree is cheap, and the expensive RenderObject updates only happen for actual changes - similar to React's virtual DOM diffing."

**Q: Why does Flutter draw its own UI instead of using platform components?**

> "Flutter uses the Skia graphics engine to paint every pixel directly to a canvas. This means:
> 1. **Pixel-perfect consistency** - A button looks identical on iOS and Android
> 2. **No platform version issues** - The UI doesn't depend on the OS version
> 3. **Full control** - Custom animations and effects without platform limitations
>
> The tradeoff is app size (~5-10MB overhead for the engine) and that it doesn't automatically match platform conventions unless you specifically use `CupertinoWidget` for iOS styling."

**Q: What's `BuildContext` and why does it matter?**

> "BuildContext is a reference to a widget's position in the Element tree. It's how widgets access things above them in the tree:
>
> - `Theme.of(context)` - walks up to find the nearest Theme
> - `context.read<AuthProvider>()` - walks up to find the nearest Provider
> - `MediaQuery.of(context)` - gets screen size information
>
> A common mistake: using context in `initState()`. The context isn't fully configured there, which is why we use `didChangeDependencies()` or `Future.microtask()` for context-dependent initialization."

**Q: Explain `Consumer` vs `context.watch` in Provider.**

> "Both subscribe to state changes, but `Consumer` limits the rebuild scope:
>
> ```dart
> // context.watch - ENTIRE build method reruns
> Widget build(BuildContext context) {
>   final auth = context.watch<AuthProvider>(); // Whole widget rebuilds
>   return Scaffold(
>     appBar: AppBar(title: Text('Home')),  // Rebuilds (wasteful!)
>     body: Text(auth.user?.email ?? ''),   // Rebuilds (needed)
>   );
> }
>
> // Consumer - ONLY the builder reruns
> Scaffold(
>   appBar: AppBar(title: Text('Home')),  // Never rebuilds
>   body: Consumer<AuthProvider>(
>     builder: (_, auth, __) {
>       return Text(auth.user?.email ?? '');  // Only this rebuilds
>     },
>   ),
> )
> ```
> In my blog app, the login screen uses `Consumer` for the error message and submit button, so the form fields don't wastefully rebuild."

---

### Category 4: Supabase & Cross-Platform Integration

**Q: How does the Supabase Dart client differ from the JavaScript client?**

> "The API surface is nearly identical. Key differences:
>
> | Aspect | JavaScript | Dart |
> |--------|-----------|------|
> | Import | `import { createClient } from '@supabase/supabase-js'` | `import 'package:supabase_flutter/supabase_flutter.dart'` |
> | Init | `createClient(url, key)` | `Supabase.initialize(url: url, anonKey: key)` |
> | Response | `const { data, error } = await ...` | `final data = await ...` (throws on error) |
> | Types | Manual TypeScript generics | Dart type inference from model classes |
> | Auth listener | Callback function | Dart Stream with `.listen()` |
>
> The biggest difference: JavaScript returns `{ data, error }` objects, while Dart throws exceptions on errors. That's why I wrap Supabase calls in try/catch blocks."

**Q: How does your Flutter app share the same database as the React app?**

> "Supabase is just a PostgreSQL database with REST and auth APIs. Both apps connect using the same URL and anon key. The database tables, Row Level Security policies, and auth users are shared. A user who signed up in the React app can log into the Flutter app with the same credentials.
>
> The only Flutter-specific setup is `Supabase.initialize()` in `main.dart` and the `supabase_flutter` package which handles auth token persistence and deep linking on mobile."

**Q: How do you handle auth tokens in Flutter vs web?**

> "On web, Supabase stores the JWT in localStorage. On Flutter mobile, `supabase_flutter` automatically uses secure storage (SharedPreferences/Keychain). The auth state listener (`onAuthStateChange`) works the same way - it's a Stream in Dart vs a callback in JavaScript. In my app, `AuthProvider._init()` subscribes to this stream and updates the app state on sign-in/sign-out events."

---

### Category 5: Blog-Specific Architecture Questions

**Q: Walk me through the complete data flow when a user creates a blog post.**

> "1. **Screen Layer**: User fills in `CreateBlogScreen` - title and content are held in `TextEditingController` objects (local state). Optionally picks an image via `ImagePicker`.
>
> 2. **Validation**: On tap 'Publish', the `Form` widget validates all fields using `_formKey.currentState!.validate()`. Each `TextFormField` has a `validator` function.
>
> 3. **Provider Layer**: Screen calls `context.read<BlogProvider>().createBlog(...)`. The provider sets `_submitting = true` and calls `notifyListeners()` - the button shows a loading spinner.
>
> 4. **Service Layer**: Provider calls `BlogService.createBlog(...)` which constructs the Supabase query: `supabase.from('blogs').insert({...}).select('*, profiles(*)').single()`.
>
> 5. **Database**: Supabase inserts the row, RLS policies verify the user has permission, and returns the created blog with joined profile data.
>
> 6. **Return Path**: Service returns `BlogModel.fromJson(response)`. Provider adds it to `_blogs` list, calls `notifyListeners()`. Any screen watching `BlogProvider` auto-rebuilds. Router navigates to the detail screen."

**Q: How do you handle errors in your app?**

> "Three levels:
> 1. **AuthException** (Supabase-specific): Caught separately in `on AuthException catch (e)` - shows Supabase's error message directly (like 'Invalid login credentials').
> 2. **General exceptions**: Caught in `catch (e)` - I display the error string so users know what happened.
> 3. **Network errors**: SocketException when the device can't reach Supabase - shows as a connection error.
>
> In Providers, errors are stored in `_errorMessage` and displayed via `Consumer` widgets that only show when `errorMessage != null`."

**Q: How does the auth guard (route protection) work?**

> "In `app_router.dart`, GoRouter has a `redirect` function that runs before every navigation. It checks `Supabase.instance.client.auth.currentSession`:
>
> - No session + trying to access protected route → redirect to `/login`
> - Has session + on login/register page → redirect to `/` (home)
> - Has session + accessing any other route → allow through (return null)
>
> The `refreshListenable` is connected to auth state changes, so when a user logs in or out, the router automatically re-evaluates all redirect conditions."

---

### Category 6: Tricky/Advanced Questions They Might Ask

**Q: What happens if you call `setState()` after the widget is disposed?**

> "It throws a 'setState called after dispose' error. This happens when an async operation completes after the user has already navigated away. That's why I check `if (mounted)` before calling `setState()`:
>
> ```dart
> final result = await someAsyncCall();
> if (mounted) {
>   setState(() => _data = result);
> }
> ```
> The `mounted` property tells you if the widget's State object is still in the tree."

**Q: Why do you `dispose()` TextEditingControllers?**

> "Controllers allocate system resources (listeners, native platform text input connections). If not disposed, they leak memory. The `dispose()` method in `State` is called when the widget is removed from the tree permanently - it's the cleanup phase. It's similar to returning a cleanup function from `useEffect` in React."

**Q: What's the difference between `go()` and `push()` in GoRouter?**

> "`context.go('/blog/123')` replaces the entire navigation stack. The user CAN'T go back. Use this for top-level navigation like going from login to home.
>
> `context.push('/blog/123')` adds to the stack. The user CAN go back with the back button. Use this for drilling into detail screens.
>
> In my app: after login succeeds, I use `context.go('/')` because I don't want the user to press 'back' and end up at the login screen again. But when tapping a blog card, I use `context.push('/blog/$id')` so they can go back to the list."

**Q: How would you add real-time updates to the blog feed?**

> "Supabase supports real-time subscriptions via PostgreSQL's LISTEN/NOTIFY. In Dart, I'd use Supabase's `.stream()` method:
>
> ```dart
> supabase.from('blogs')
>     .stream(primaryKey: ['id'])
>     .order('created_at', ascending: false)
>     .listen((data) {
>       final blogs = data.map(BlogModel.fromJson).toList();
>       updateState(blogs);
>     });
> ```
> This creates a WebSocket connection and pushes updates whenever the `blogs` table changes. I'd put this in the BlogProvider's init and cancel the subscription in dispose."

**Q: How would you implement pagination in the blog list?**

> "I use offset-based pagination with Supabase's `.range()`:
>
> ```dart
> final data = await supabase
>     .from('blogs')
>     .select('*, profiles(*)')
>     .order('created_at', ascending: false)
>     .range(offset, offset + pageSize - 1);
> ```
>
> In the UI, I attach a `ScrollController` to the `ListView` and listen for when the user scrolls near the bottom. When they do, I increment the offset and fetch the next page. The provider appends new blogs to the existing list rather than replacing them."

---

### Assessment Scoring - What Interviewers Typically Look For

| Criteria | Fail | Pass | Excellent |
|----------|------|------|-----------|
| **App works** | Doesn't run | Runs with basic features | All features work smoothly |
| **Code understanding** | Can't explain own code | Explains what code does | Explains WHY and trade-offs |
| **Dart knowledge** | Doesn't know basics | Understands null safety, async, classes | Can discuss type system, const optimization |
| **Flutter concepts** | Confused about widgets | Knows Stateless vs Stateful | Understands three trees, lifecycle, keys |
| **Architecture** | Spaghetti code, no structure | Has separation of concerns | Can justify every architectural decision |
| **Supabase** | Can't explain queries | Basic CRUD knowledge | Understands auth flow, RLS, real-time |
| **Problem solving** | Gives up on unknowns | Attempts reasonable answers | Thinks through problems methodically |

---

Good luck with your interview!
