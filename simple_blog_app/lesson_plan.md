# Flutter/Dart Learning Lesson Plan
> Simple explanations for beginners - Job assessment prep

---

## Module 0: What is Flutter & Dart?

### Super Simple Explanation

**Dart** = The programming language (like JavaScript)
**Flutter** = The framework that uses Dart to build apps (like React)

```
JavaScript + React   = Web apps
Dart + Flutter       = Mobile apps (iOS + Android) + Web + Desktop
```

### What is Dart?

**In plain English:** Dart is Google's programming language. It's similar to JavaScript but with stricter rules (which is actually good - catches errors early!).

**Quick history:**
- 2011: Google creates Dart (wanted to replace JavaScript)
- 2017: Flutter comes out, Dart becomes "the Flutter language"
- Today: You learn Dart mainly to use Flutter

**Why Dart instead of JavaScript?**
| Problem in JavaScript | How Dart fixes it |
|-----------------------|-------------------|
| `null` and `undefined` confusion | Only `null` exists |
| `this` keyword is confusing | `this` always means the same thing |
| Types are optional | Types help catch bugs early |
| Semicolons are optional (causes bugs) | Semicolons required |

### What is Flutter?

**In plain English:** Flutter is Google's toolkit for building apps. Write code once, run on iPhone, Android, Web, and Desktop!

**The Problem Flutter Solves:**
```
Before Flutter:
- Want an iPhone app? Learn Swift, use Xcode
- Want an Android app? Learn Kotlin, use Android Studio
- Want both? Build TWO separate apps! (2x the work, 2x the bugs)

With Flutter:
- Write ONE app in Dart
- Run it on iPhone AND Android AND Web AND Desktop
- Same look, same behavior everywhere
```

**Who uses Flutter?**
Google, Alibaba, BMW, eBay, and 500,000+ apps worldwide.

**The magic:** Flutter draws its own buttons, text, everything. It doesn't use iPhone's buttons or Android's buttons. It paints everything from scratch. That's why your app looks IDENTICAL on all devices.

### Flutter vs React Native (Simple Comparison)

| | Flutter | React Native |
|---|---------|--------------|
| **Language** | Dart | JavaScript |
| **Made by** | Google | Facebook |
| **How it looks** | Same on ALL devices | Looks different per device |
| **Speed** | Faster (no bridge) | Slower (has a bridge) |
| **If you know React** | Need to learn Dart | Easier to start |

**Which to choose?**
- Know React well? → React Native might be faster to learn
- Want identical look everywhere? → Flutter
- Building for a company? → Check what they use

### Key Flutter Concept: Everything is a Widget

**What's a Widget?** A widget is a piece of UI. Everything you see is a widget!

```dart
Text('Hello')                    // Text widget - shows text
ElevatedButton(...)              // Button widget - clickable button
Column(children: [...])          // Column widget - stacks things vertically
Container(...)                   // Container widget - like a <div>
```

**Widgets inside widgets (like Russian dolls):**
```
App
 └── Screen
      └── Column (vertical stack)
           ├── Text('Title')
           ├── Image(...)
           └── Button('Click me')
```

### Dart vs JavaScript (What You Need to Know)

| JavaScript | Dart | Notes |
|------------|------|-------|
| `let x = 5` | `var x = 5` | Almost the same! |
| `const x = 5` | `final x = 5` | Can't reassign |
| `async/await` | `async/await` | Same! |
| `Promise` | `Future` | Same concept, different name |
| `` `Hello ${name}` `` | `'Hello $name'` | String interpolation |
| Semicolons optional | Semicolons required | Dart needs them |

### Why Learn Flutter? (For Your Interview)

**Simple answer:** "Flutter lets me build one app that runs on iOS, Android, Web, and Desktop. It's fast, has great developer tools like hot reload, and Google uses it in their own apps."

**Job market:** Flutter developers are in demand, and there are fewer of them than React Native developers = less competition!

---

## Module 1: Dart Language Fundamentals

### 1.1 Variables (Super Simple)

**Creating variables:**
```dart
var name = 'John';     // Dart figures out it's a String
String name = 'John';  // You tell Dart it's a String (same thing)
int age = 25;          // Integer (whole number)
double price = 9.99;   // Decimal number
bool isActive = true;  // true or false
```

**Can't change vs Can change:**
```dart
var name = 'John';     // CAN change later: name = 'Jane';
final name = 'John';   // CAN'T change (like JS const)
const pi = 3.14;       // CAN'T change (even stricter)
```

**Simple rule:** Use `final` most of the time. Use `var` if you need to change it later.

**Nullable (can be empty):**
```dart
String name = 'John';   // MUST have a value, can't be null
String? name = null;    // The ? means "this CAN be null"
```

### 1.2 Functions (Super Simple)

**Basic function:**
```dart
// JavaScript
function greet(name) {
  return 'Hello ' + name;
}

// Dart (almost the same!)
String greet(String name) {
  return 'Hello $name';
}
```

**Short version (arrow function):**
```dart
// If your function is just ONE line, use =>
String greet(String name) => 'Hello $name';
```

**Named parameters (you'll see this A LOT in Flutter):**
```dart
// With named parameters - order doesn't matter!
void createUser({required String name, int? age}) {
  print('Name: $name, Age: $age');
}

// Calling it:
createUser(name: 'John', age: 25);
createUser(age: 25, name: 'John');  // Same thing! Order doesn't matter
```

**Why named parameters?** Makes code easier to read:
```dart
// Without names (confusing - what's true? what's 10?)
createButton('Submit', true, 10, false);

// With names (clear!)
createButton(text: 'Submit', isEnabled: true, width: 10, isRound: false);
```

### 1.3 Classes (Super Simple)

**Basic class:**
```dart
class User {
  String name;
  String email;

  // Constructor - runs when you create a new User
  User(this.name, this.email);  // Shortcut! Auto-assigns to fields
}

// Creating a user:
var user = User('John', 'john@email.com');
print(user.name);  // John
```

**With named parameters (common in Flutter):**
```dart
class User {
  final String name;
  final String email;

  User({required this.name, required this.email});
}

// Creating:
var user = User(name: 'John', email: 'john@email.com');
```

**fromJson - turning data into an object:**
```dart
class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  // Factory = special constructor that can do stuff before creating
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
    );
  }
}

// Using it (when you get data from API):
var data = {'name': 'John', 'email': 'john@email.com'};
var user = User.fromJson(data);
```

### 1.4 Async/Await (Super Simple)

**The concept:** Sometimes code takes time (loading data from internet). We don't want the app to freeze while waiting!

**JavaScript vs Dart - almost identical!**
```javascript
// JavaScript
async function fetchUser() {
  const response = await fetch('/api/user');
  return response.json();
}
// Returns: Promise<User>
```

```dart
// Dart
Future<User> fetchUser() async {
  final response = await http.get('/api/user');
  return User.fromJson(response.body);
}
// Returns: Future<User>
```

**Key point:** `Future` in Dart = `Promise` in JavaScript. Same thing, different name!

**Simple example:**
```dart
// Function that takes time
Future<String> fetchName() async {
  await Future.delayed(Duration(seconds: 2));  // Wait 2 seconds
  return 'John';
}

// Using it
void main() async {
  print('Loading...');
  String name = await fetchName();  // Waits here
  print('Got: $name');
}
```

### 1.5 Null Safety (Super Simple)

**The problem:** In JavaScript, anything can be `null` or `undefined`, causing crashes.

**Dart's solution:** You must SAY if something can be null.

```dart
String name = 'John';    // This CANNOT be null. Ever.
String? name = null;     // The ? means "this CAN be null"
```

**Dealing with nullable values:**
```dart
String? maybeName = getName();  // Might return null

// Option 1: Default value if null
String name = maybeName ?? 'Unknown';

// Option 2: Only access if not null
int? length = maybeName?.length;  // null if maybeName is null

// Option 3: I PROMISE it's not null (dangerous!)
String name = maybeName!;  // Crashes if it IS null
```

**Simple rule:**
- No `?` = guaranteed to have a value
- Has `?` = might be null, handle it!

---

## Module 2: Flutter Core Concepts

### 2.1 The Two Types of Widgets

**Simple rule:**
- **StatelessWidget** = Never changes (like a photo)
- **StatefulWidget** = Can change (like a video)

```
StatelessWidget: "I display data. I don't change."
                 Examples: Text, Icon, Image

StatefulWidget:  "I have buttons, forms, things that change!"
                 Examples: Checkbox, TextField, Counter
```

### 2.2 StatelessWidget (The Simple One)

**When to use:** When your widget just displays stuff and never changes.

```dart
// A simple greeting that never changes
class Greeting extends StatelessWidget {
  final String name;  // Data passed in

  const Greeting({required this.name});  // Constructor

  @override
  Widget build(BuildContext context) {
    return Text('Hello $name');  // What to display
  }
}

// Using it:
Greeting(name: 'John')  // Shows: Hello John
```

**Think of it like:** A name tag. Once printed, it doesn't change.

### 2.3 StatefulWidget (The Changing One)

**When to use:** When something needs to change (counters, forms, toggles).

```dart
class Counter extends StatefulWidget {
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;  // This is the "state" - data that changes

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {    // setState = "Hey Flutter, something changed!"
          count++;       // Update the data
        });              // Flutter redraws the widget
      },
      child: Text('Count: $count'),
    );
  }
}
```

**The magic word: `setState()`**
- Call `setState()` when data changes
- Flutter redraws the widget with new data
- Like React's `useState` setter!

### 2.4 Lifecycle (When Things Happen)

```dart
class MyWidget extends StatefulWidget { ... }

class _MyWidgetState extends State<MyWidget> {

  @override
  void initState() {
    super.initState();
    // Runs ONCE when widget is created
    // Good for: Loading initial data, setting up listeners
  }

  @override
  Widget build(BuildContext context) {
    // Runs EVERY TIME the widget needs to redraw
    return Text('Hello');
  }

  @override
  void dispose() {
    // Runs when widget is removed
    // Good for: Cleanup, cancel subscriptions
    super.dispose();
  }
}
```

**Simple version:**
| When | Method | Use for |
|------|--------|---------|
| Widget created | `initState()` | Load data, setup |
| Widget redraws | `build()` | Return UI |
| Widget removed | `dispose()` | Cleanup |

### 2.5 Layout Widgets (Like CSS Flexbox)

**The 3 layouts you'll use 90% of the time:**

```dart
// COLUMN = Stack things vertically (top to bottom)
Column(
  children: [
    Text('First'),
    Text('Second'),
    Text('Third'),
  ],
)

// ROW = Stack things horizontally (left to right)
Row(
  children: [
    Icon(Icons.star),
    Text('Rating'),
  ],
)

// CONTAINER = A box (like <div>)
Container(
  padding: EdgeInsets.all(16),
  color: Colors.blue,
  child: Text('Inside a box'),
)
```

**Quick CSS to Flutter translation:**
| CSS | Flutter |
|-----|---------|
| `<div>` | `Container()` |
| `flex-direction: column` | `Column()` |
| `flex-direction: row` | `Row()` |
| `padding: 16px` | `padding: EdgeInsets.all(16)` |
| `margin: 16px` | `margin: EdgeInsets.all(16)` |
| `justify-content: center` | `mainAxisAlignment: MainAxisAlignment.center` |
| `align-items: center` | `crossAxisAlignment: CrossAxisAlignment.center` |

### 2.6 Theming in Flutter (PHASE 1 COMPLETE!)

#### Simple Explanation

**What is a Theme?**
Think of a theme like choosing an outfit for your app:
- Instead of picking colors for EVERY button, text, and card separately...
- You pick ONE color scheme, and the app wears it everywhere!

**Real-world analogy:**
```
WITHOUT Theme: "Make this button blue, that button blue,
               this text dark gray, that text dark gray..." (100 times)

WITH Theme:    "Hey app, your main color is blue, text is dark gray."
               App: "Got it! I'll use those everywhere automatically."
```

#### The 3 Things You Need to Know

**1. Where to set the theme (in main.dart):**
```dart
MaterialApp(
  theme: AppTheme.lightTheme,      // Day mode colors
  darkTheme: AppTheme.darkTheme,   // Night mode colors
  themeMode: ThemeMode.system,     // Phone decides which to use
)
```

**2. The main colors you define:**
```
primary    = Your brand color (we chose Indigo)
            → Used for: buttons, links, active items

secondary  = Accent color (we chose Purple)
            → Used for: floating buttons, switches

surface    = Background of cards and popups
            → Light mode: white | Dark mode: dark gray

error      = Red for mistakes
            → Used for: error messages, delete buttons
```

**3. How to use theme colors in your widgets:**
```dart
// WRONG WAY (hardcoded - don't do this!)
Container(color: Color(0xFF6366F1))  // What if we change the brand color?

// RIGHT WAY (uses theme - do this!)
Container(color: Theme.of(context).colorScheme.primary)  // Auto-updates!
```

#### Quick Reference

| What you want | Code |
|---------------|------|
| Get primary color | `Theme.of(context).colorScheme.primary` |
| Get text color | `Theme.of(context).colorScheme.onSurface` |
| Check if dark mode | `Theme.of(context).brightness == Brightness.dark` |

#### TL;DR (Summary)

1. **Theme** = one place to define all your app's colors
2. **ThemeData** = the container holding all those colors
3. **ColorScheme** = your color palette (primary, secondary, error, etc.)
4. **Theme.of(context)** = how you access colors in any widget
5. **ThemeMode.system** = let the phone decide light/dark mode

### 2.7 Data Models (PHASE 2 COMPLETE!)

#### What is a Model?

**Real-world analogy:**
```
A model is like a FORM at the doctor's office:

  Name: ________  (required, text)
  Age:  ________  (required, number)
  Notes: ________ (optional, text)

The form TELLS you what data is needed and what type it should be.
```

**Without models:**
```dart
// BAD - just a Map, easy to make mistakes
var user = {'naem': 'John', 'emial': 'test'};  // Typos! No warning!
print(user['name']);  // Returns null... why?? (because you typed 'naem')
```

**With models:**
```dart
// GOOD - Dart catches mistakes
var user = UserModel(name: 'John', email: 'test');
print(user.name);  // Works! Dart knows the fields
print(user.naem);  // ERROR! Dart says "naem doesn't exist" - saved!
```

#### The Pattern Every Model Follows

```dart
class SomeModel {
  // 1. FIELDS - what data it holds
  final String name;
  final String? optionalField;  // ? = can be null

  // 2. CONSTRUCTOR - how to create one
  SomeModel({required this.name, this.optionalField});

  // 3. fromJson - turn API data INTO a model
  factory SomeModel.fromJson(Map<String, dynamic> json) {
    return SomeModel(name: json['name']);
  }

  // 4. toJson - turn model INTO API data
  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
```

#### The 4 Models in Our App

| Model | Table | What it holds |
|-------|-------|---------------|
| `UserModel` | Auth (auto) | id, email, createdAt |
| `ProfileModel` | profiles | username, bio, avatar |
| `BlogModel` | blogs | title, content, image, authorId |
| `CommentModel` | comments | content, blogId, authorId |

**How they connect:**
```
UserModel (login credentials)
  └── ProfileModel (social profile, same ID)
        └── BlogModel (posts by this user)
              └── CommentModel (comments on this post)
```

#### New Concept: copyWith()

```dart
// Models are 'final' - you can't change them directly
profile.bio = 'New bio';  // ERROR! Can't do this

// Instead, create a NEW copy with the change
final updated = profile.copyWith(bio: 'New bio');
// Everything else stays the same, only bio changes
```

#### TL;DR

1. **Model** = blueprint for your data (like TypeScript interface)
2. **fromJson** = turn API data into a Dart object
3. **toJson** = turn Dart object into API data
4. **copyWith** = create a copy with some changes
5. **required** = must provide, **?** = optional

### 2.8 Supabase Services (PHASE 3 COMPLETE!)

#### What is a Service?

**Real-world analogy:**
```
Think of a restaurant:

  You (the app screens)  → "I want a burger"
  Waiter (the service)   → Goes to kitchen, brings burger back
  Kitchen (Supabase)     → Makes the burger

The SERVICE is the middleman between your app and the database.
You never go to the kitchen yourself!
```

**Why not just call Supabase directly from screens?**
```
WITHOUT Services (messy):
  LoginScreen → calls Supabase directly
  ProfileScreen → calls Supabase directly
  BlogScreen → calls Supabase directly
  (Same Supabase code copied everywhere!)

WITH Services (clean):
  LoginScreen → asks AuthService → AuthService talks to Supabase
  ProfileScreen → asks AuthService → AuthService talks to Supabase
  BlogScreen → asks BlogService → BlogService talks to Supabase
  (One place for each operation!)
```

#### Our 2 Services

| Service | What it does | Like in JavaScript... |
|---------|-------------|----------------------|
| `AuthService` | Login, signup, profiles | Your `auth.js` or `authApi.js` |
| `BlogService` | Create/read/update/delete blogs & comments | Your `blogApi.js` |

#### Key Concept: Future (= JavaScript Promise)

```dart
// JavaScript
async function getBlogs() {          // Returns Promise<Blog[]>
  const { data } = await supabase
    .from('blogs').select();
  return data;
}

// Dart (almost identical!)
Future<List<BlogModel>> getBlogs() async {  // Returns Future<List<BlogModel>>
  final response = await _supabase
      .from('blogs').select();
  return response.map((json) => BlogModel.fromJson(json)).toList();
}
```

**Simple rule:** `Future` = "I'll give you the answer later" (same as Promise)

#### Key Concept: Stream (= JavaScript Event Listener)

```
Future vs Stream:

  Future: "Go get me coffee" → waits → gets ONE coffee → done
  Stream: "Tell me EVERY TIME someone enters" → fires again and again

  Future = fetch data once (like Promise)
  Stream = listen for changes over time (like addEventListener)
```

```dart
// JavaScript event listener
supabase.auth.onAuthStateChange((event, session) => {
  console.log('Auth changed!', event);
});

// Dart Stream (same concept!)
_supabase.auth.onAuthStateChange.listen((data) {
  print('Auth changed! ${data.event}');
});
```

**When to use which:**
| Use | When |
|-----|------|
| `Future` | Fetching blogs, creating a post, logging in |
| `Stream` | Listening for auth changes (login/logout events) |

#### AuthService - What Each Method Does

| Method | What it does | Returns |
|--------|-------------|---------|
| `signUp(email, password)` | Create new account | `Future<AuthResponse>` |
| `signIn(email, password)` | Login existing user | `Future<AuthResponse>` |
| `signOut()` | Logout | `Future<void>` (nothing) |
| `currentUser` | Get logged-in user | `User?` (or null) |
| `onAuthStateChange` | Listen for login/logout | `Stream<AuthState>` |
| `createProfile(userId, username)` | Make profile after signup | `Future<void>` |
| `getProfile(userId)` | Get user's profile | `Future<ProfileModel?>` |
| `updateProfile(userId, ...)` | Edit profile | `Future<void>` |

#### BlogService - What Each Method Does

| Method | What it does | Returns |
|--------|-------------|---------|
| `getBlogs()` | Get ALL blogs (newest first) | `Future<List<BlogModel>>` |
| `getBlogById(id)` | Get ONE blog | `Future<BlogModel>` |
| `getUserBlogs(userId)` | Get blogs by one user | `Future<List<BlogModel>>` |
| `createBlog(title, content, ...)` | Create new blog | `Future<BlogModel>` |
| `updateBlog(blogId, ...)` | Edit a blog | `Future<BlogModel>` |
| `deleteBlog(blogId)` | Delete a blog | `Future<void>` |
| `getComments(blogId)` | Get comments on a blog | `Future<List<CommentModel>>` |
| `addComment(content, blogId, ...)` | Add a comment | `Future<CommentModel>` |
| `deleteComment(commentId)` | Delete a comment | `Future<void>` |

#### Supabase Query Pattern (JS vs Dart)

The queries look almost identical!

```javascript
// JavaScript
const { data } = await supabase
  .from('blogs')
  .select('*, profiles(username, avatar_url)')
  .eq('author_id', userId)
  .order('created_at', { ascending: false });
```

```dart
// Dart
final data = await supabase
    .from('blogs')
    .select('*, profiles(username, avatar_url)')
    .eq('author_id', userId)
    .order('created_at', ascending: false);
```

**Spot the differences:**
1. `const { data }` → `final data` (no destructuring in Dart)
2. `{ ascending: false }` → `ascending: false` (named parameter, no wrapping object)
3. That's it! The Supabase API is basically the same.

#### What's `.select('*, profiles(username, avatar_url)')`?

This is a JOIN - getting related data from another table in one query.

```
blogs table:          profiles table:
┌────────┬───────┐   ┌────────┬──────────┐
│ title  │ author│   │ id     │ username │
├────────┼───────┤   ├────────┼──────────┤
│ My Post│ abc123│──→│ abc123 │ john_doe │
└────────┴───────┘   └────────┴──────────┘

select('*, profiles(username)')
= "Get all blog fields AND the author's username from profiles table"
```

#### `.maybeSingle()` vs `.single()`

```dart
// .single() = "I EXPECT exactly ONE result. Crash if zero or many."
final blog = await supabase.from('blogs').select().eq('id', blogId).single();

// .maybeSingle() = "Give me one result OR null. Don't crash."
final profile = await supabase.from('profiles').select().eq('id', id).maybeSingle();
```

**When to use:**
- `.single()` → When you KNOW it exists (getting a blog by ID)
- `.maybeSingle()` → When it MIGHT not exist (checking if profile was created)

#### TL;DR

1. **Service** = middleman between your app and database
2. **Future** = Promise (get data once, like `fetch()`)
3. **Stream** = Event listener (fires multiple times, like `addEventListener`)
4. **Supabase queries** = Almost identical in JS and Dart
5. **AuthService** = handles login, signup, profiles
6. **BlogService** = handles CRUD for blogs and comments

---

## Module 3: State Management (Provider)

### 3.0 Global vs Local State (INTERVIEW CRITICAL!)

**What is State?**
State = data that can change over time and affects what the UI displays.

#### Local State (UI State / Ephemeral State)
Data that belongs to a **single widget** and doesn't need to be shared.

| Example | Why Local? |
|---------|------------|
| Text field input value | Only that form needs it |
| Is password visible toggle | Only that input needs it |
| Current tab index | Only that TabBar needs it |
| Form validation errors | Only that form needs it |
| Animation progress | Only that widget animates |
| Dropdown open/closed | Only that dropdown needs it |

```dart
// Local state with StatefulWidget
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // LOCAL STATE - only this widget needs these
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // Uses local state
  }
}
```

#### Global State (App State / Shared State)
Data that **multiple widgets** need access to, or must **survive navigation**.

| Example | Why Global? |
|---------|-------------|
| Current logged-in user | Many screens check auth |
| User's profile data | Shown in multiple places |
| List of blog posts | Multiple screens display |
| Theme mode (dark/light) | Affects entire app |
| Shopping cart items | Persists across screens |
| Notification count | Shown in multiple places |

```dart
// Global state with Provider
class AuthProvider extends ChangeNotifier {
  // GLOBAL STATE - many widgets need this
  User? _currentUser;
  Profile? _userProfile;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
}
```

### 3.0.1 State Map for This Blog App

```
┌─────────────────────────────────────────────────────────────────┐
│                        GLOBAL STATE                              │
│                   (Provider/ChangeNotifier)                      │
├─────────────────────────────────────────────────────────────────┤
│  AuthProvider                                                    │
│  ├── currentUser (User?)         → Who is logged in             │
│  ├── userProfile (Profile?)      → Username, avatar, bio        │
│  ├── isAuthenticated (bool)      → Quick auth check             │
│  └── isLoading (bool)            → Auth operations loading      │
├─────────────────────────────────────────────────────────────────┤
│  BlogProvider                                                    │
│  ├── blogs (List<Blog>)          → All blog posts               │
│  ├── selectedBlog (Blog?)        → Currently viewing            │
│  ├── myBlogs (List<Blog>)        → Current user's blogs         │
│  ├── isLoading (bool)            → Fetching blogs               │
│  └── error (String?)             → Error message                │
├─────────────────────────────────────────────────────────────────┤
│  ThemeProvider                                                   │
│  ├── themeMode (ThemeMode)       → light/dark/system            │
│  └── toggleTheme()               → Switch theme                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        LOCAL STATE                               │
│                      (StatefulWidget)                            │
├─────────────────────────────────────────────────────────────────┤
│  LoginScreen                                                     │
│  ├── emailController             → Email input text             │
│  ├── passwordController          → Password input text          │
│  ├── isPasswordVisible           → Show/hide password           │
│  ├── isSubmitting                → Button loading state         │
│  └── formErrors                  → Validation messages          │
├─────────────────────────────────────────────────────────────────┤
│  CreateBlogScreen                                                │
│  ├── titleController             → Title input text             │
│  ├── contentController           → Content input text           │
│  ├── selectedImage               → Picked image file            │
│  ├── isSubmitting                → Publishing state             │
│  └── formKey                     → Form validation              │
├─────────────────────────────────────────────────────────────────┤
│  BlogListScreen                                                  │
│  ├── isRefreshing                → Pull-to-refresh state        │
│  ├── searchQuery                 → Search filter text           │
│  └── scrollController            → Scroll position              │
├─────────────────────────────────────────────────────────────────┤
│  BlogDetailScreen                                                │
│  ├── commentController           → New comment input            │
│  ├── isLiked                     → User liked this post         │
│  └── isSubmittingComment         → Comment posting state        │
└─────────────────────────────────────────────────────────────────┘
```

### 3.0.2 Web vs Mobile State Management

| Aspect | Web (React) | Mobile (Flutter) |
|--------|-------------|------------------|
| **State lost when...** | Page refresh, tab close | App killed, device restart |
| **URL as state** | Yes! `/blog/123` is state | No URL bar (use routes internally) |
| **Back button** | Browser handles | You manage navigation stack |
| **Multiple tabs** | Each tab = separate state | Single instance |
| **Background** | Tab can be "frozen" | App can be killed anytime |
| **Persistence** | localStorage, sessionStorage | SharedPreferences, SQLite |
| **Deep linking** | Native (URLs) | Must configure (go_router) |

#### Key Differences Explained:

**1. No URL State in Mobile**
```javascript
// Web (React) - URL IS state
// User at /blog/123 means "viewing blog 123"
// Refresh? Still at /blog/123

useEffect(() => {
  const blogId = router.query.id;  // State from URL
  fetchBlog(blogId);
}, [router.query.id]);
```

```dart
// Mobile (Flutter) - Must manage ourselves
// If app is killed and reopened, user is at home screen
// Deep links require explicit setup

GoRoute(
  path: '/blog/:id',
  builder: (context, state) {
    final blogId = state.pathParameters['id']!;
    return BlogDetailScreen(blogId: blogId);
  },
)
```

**2. App Lifecycle Matters in Mobile**
```dart
// Mobile apps can be killed anytime!
// Must save important state

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App going to background - save state!
      _saveCurrentState();
    }
    if (state == AppLifecycleState.resumed) {
      // App coming back - restore/refresh
      _refreshData();
    }
  }
}
```

**3. Persistence Strategy Differs**

| Web | Mobile |
|-----|--------|
| `localStorage.setItem('theme', 'dark')` | `SharedPreferences.setString('theme', 'dark')` |
| Cookies for auth tokens | Secure storage for tokens |
| IndexedDB for large data | SQLite / Hive for large data |
| Session = tab lifetime | Session = until logout |

```dart
// Flutter - SharedPreferences for simple persistence
final prefs = await SharedPreferences.getInstance();
await prefs.setString('theme', 'dark');

// Reading back
final theme = prefs.getString('theme') ?? 'light';
```

**4. Navigation State**

```javascript
// Web - Browser manages history
window.history.back();  // Browser's back button works
```

```dart
// Mobile - You manage the stack
Navigator.pop(context);  // Your code handles back
context.go('/home');     // Replace entire stack
context.push('/detail'); // Add to stack

// Android back button? You handle it:
WillPopScope(
  onWillPop: () async {
    // Custom back behavior
    return true; // Allow pop
  },
  child: MyScreen(),
)
```

**5. When to Persist State (Mobile-Specific)**

| State | Persist? | Why |
|-------|----------|-----|
| Auth token | YES (secure) | Don't make user login every time |
| Theme preference | YES | Remember user's choice |
| Draft blog post | YES | Don't lose user's work |
| Scroll position | MAYBE | Nice UX, not critical |
| Search query | NO | Ephemeral, user will search again |
| Form input | MAYBE | Only if long form |

### 3.0.3 Interview Answer Template

**Q: "What's the difference between global and local state?"**

> "Local state is data that only one widget needs - like form input values, loading spinners, or toggle states. It stays inside the widget with `setState()`.
>
> Global state is data that multiple widgets need access to, or data that must survive navigation - like the logged-in user, theme preferences, or a list of items. We use state management solutions like Provider, Riverpod, or BLoC to share this across the widget tree.
>
> For example, in a blog app: the text in a comment input box is local state - only that input needs it. But the current user's profile is global state - the header shows it, the profile screen shows it, and we need it when creating posts."

**Q: "How does state management differ between web and mobile?"**

> "The biggest difference is that web has URL as implicit state - `/blog/123` tells you what to show. Mobile doesn't have a URL bar, so we manage navigation state ourselves with routers.
>
> Second, mobile apps can be killed by the OS anytime to save memory. We need to persist important state to SharedPreferences or a database. Web apps only lose state on refresh or tab close.
>
> Third, mobile has lifecycle events - paused, resumed, detached - that we must handle to save state when the app goes to background. Web doesn't have this concern the same way."

### 3.1 ChangeNotifier Pattern (PHASE 4 COMPLETE!)

#### What is ChangeNotifier?

**Simple analogy:**
```
ChangeNotifier is like a radio station:
  1. The station BROADCASTS news (notifyListeners)
  2. Listeners TUNE IN (context.watch)
  3. When news comes, listeners REACT (widget rebuilds)
```

**The pattern we used in every provider:**
```dart
class AuthProvider extends ChangeNotifier {
  // 1. PRIVATE STATE (only this class can change it)
  User? _user;
  bool _isLoading = false;

  // 2. PUBLIC GETTERS (anyone can read)
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  // 3. METHODS (change state + broadcast)
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();  // "Hey everyone, I'm loading now!"

    _user = await authService.signIn(email, password);
    _isLoading = false;
    notifyListeners();  // "Hey everyone, I'm done! Here's the user!"
  }
}
```

**Why private `_` fields + public getters?**
```dart
// BAD - anyone can change the state directly
String error = 'oops';  // Any widget can do: provider.error = 'hacked';

// GOOD - only the provider can change state
String? _error;                    // Private, can't be changed from outside
String? get error => _error;      // Public, read-only access
```

### 3.2 Using Provider (PHASE 4 COMPLETE!)

**Setting up providers (in main.dart):**
```dart
// Provide at top level - like wrapping React Context providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
    ChangeNotifierProvider(create: (_) => BlogProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
  ],
  child: MyApp(),
)
```

**Using providers in widgets:**
```dart
// WATCH = rebuilds widget when data changes (use in build method)
final user = context.watch<AuthProvider>().user;

// READ = one-time read, NO rebuild (use in callbacks like onPressed)
final auth = context.read<AuthProvider>();

// WHEN TO USE WHICH:
// build() method → context.watch (need live updates)
// onPressed, onTap → context.read (just need to call a method)
```

**The `..` cascade operator (Dart trick):**
```dart
// These are the same:
final provider = AuthProvider();
provider.initialize();

// Shorter with cascade:
AuthProvider()..initialize()  // Create AND call initialize, return the object
```

#### TL;DR

1. **ChangeNotifier** = broadcasts changes to listeners
2. **notifyListeners()** = "Hey widgets, data changed! Rebuild!"
3. **context.watch()** = subscribe (widget rebuilds on change)
4. **context.read()** = one-time read (for button handlers)
5. **MultiProvider** = set up all providers at the top
6. **Private `_` + getter** = only provider can change its own state

---

## Module 4: Navigation (go_router) (PHASE 5 COMPLETE!)

### What is go_router?

**Simple analogy:**
```
go_router is like a building directory:
  "/" (lobby)              → BlogListScreen (home)
  "/login"                 → LoginScreen
  "/blog/123"              → BlogDetailScreen for blog #123
  "/profile"               → ProfileScreen

The REDIRECT is like a security guard:
  "Are you logged in? No? Go to /login!"
```

**React Router vs go_router:**
```javascript
// React Router
<Route path="/blog/:id" element={<BlogDetail />} />
const { id } = useParams();
navigate('/home');
```
```dart
// go_router (almost the same!)
GoRoute(path: '/blog/:id', builder: (_, state) => BlogDetailScreen(blogId: state.pathParameters['id']!))
context.go('/home');
```

### 4.1 Route Definition
```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
    GoRoute(
      path: '/blog/:id',
      builder: (_, state) => BlogDetailScreen(
        blogId: state.pathParameters['id']!,
      ),
    ),
  ],
  // Route guard - like a middleware
  redirect: (context, state) {
    final isLoggedIn = authProvider.isAuthenticated;
    if (!isLoggedIn && state.matchedLocation != '/login') {
      return '/login';  // Redirect to login!
    }
    return null;  // No redirect, continue
  },
);
```

### 4.2 Navigation Methods
```dart
context.go('/home');           // Replace current route (can't go back)
context.push('/blog/123');     // Add to stack (CAN go back)
context.pop();                 // Go back to previous screen

// With named routes:
context.goNamed('blog-detail', pathParameters: {'id': '123'});
```

**When to use go vs push:**
| Method | What it does | Use when |
|--------|-------------|----------|
| `context.go()` | Replace entire stack | Navigating to a new section (home, login) |
| `context.push()` | Add on top | Opening a detail page (want back button) |
| `context.pop()` | Go back | Closing current screen |

### 4.3 Route Guard (redirect)

Our app has 3 levels of access:
```
Not logged in → Force to /login
Logged in but no profile → Force to /profile-setup
Logged in with profile → Allow access to everything
```

#### TL;DR

1. **GoRouter** = Flutter's React Router
2. **`context.go()`** = replace route, **`context.push()`** = add to stack
3. **`redirect`** = route guard (check auth before showing page)
4. **`:id`** = path parameter, access with `state.pathParameters['id']`
5. **`refreshListenable`** = auto-check routes when auth changes

---

## Module 5: Supabase Integration

### 5.1 Initialization
```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
final supabase = Supabase.instance.client;
```

### 5.2 Auth Operations
```dart
// Sign up
await supabase.auth.signUp(email: email, password: password);

// Sign in
await supabase.auth.signInWithPassword(email: email, password: password);

// Sign out
await supabase.auth.signOut();

// Get current user
final user = supabase.auth.currentUser;

// Listen to auth changes
supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  final user = data.session?.user;
});
```

### 5.3 Database Operations
```dart
// SELECT * FROM blogs
final blogs = await supabase.from('blogs').select();

// SELECT with filter
final myBlogs = await supabase
    .from('blogs')
    .select()
    .eq('author_id', userId);

// INSERT
await supabase.from('blogs').insert({
  'title': title,
  'content': content,
  'author_id': userId,
});

// UPDATE
await supabase
    .from('blogs')
    .update({'title': newTitle})
    .eq('id', blogId);

// DELETE
await supabase.from('blogs').delete().eq('id', blogId);
```

---

## Module 6: Building Screens (PHASES 6-8 COMPLETE!)

### How Screens Connect Everything

```
User taps "Login" button
  → Screen calls context.read<AuthProvider>().signIn()
    → AuthProvider calls AuthService.signIn()
      → AuthService calls Supabase
        → Supabase returns user data
      → AuthService returns AuthResponse
    → AuthProvider saves user + calls notifyListeners()
  → Screen auto-rebuilds (because it watches AuthProvider)
  → Router redirects to home (because auth state changed)
```

### Key Screen Patterns We Used

**1. Form Pattern (Login, Register, Create Blog):**
```dart
class LoginScreen extends StatefulWidget { ... }

class _LoginScreenState extends State<LoginScreen> {
  // Controllers hold text values
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Clean up when screen closes
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle form submit
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;  // Check all fields
    final auth = context.read<AuthProvider>();        // Read (not watch!)
    await auth.signIn(...);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();  // Watch for loading state
    return Form(
      key: _formKey,
      child: Column(children: [
        TextFormField(controller: _emailController, validator: ...),
        ElevatedButton(
          onPressed: auth.isLoading ? null : _handleLogin,
        ),
      ]),
    );
  }
}
```

**2. List Pattern (Blog List, Profile Posts):**
```dart
// Load data when screen opens
@override
void initState() {
  super.initState();
  context.read<BlogProvider>().fetchBlogs();
}

// Display with ListView.builder
ListView.builder(
  itemCount: blogs.length,
  itemBuilder: (context, index) => BlogCard(blog: blogs[index]),
)
```

**3. Confirmation Dialog Pattern (Delete Blog, Logout):**
```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Delete?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
      TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
    ],
  ),
);
if (confirmed == true) { /* do the thing */ }
```

### React vs Flutter Widget Comparison

| React | Flutter | Notes |
|-------|---------|-------|
| `<input>` | `TextFormField` | With controller instead of onChange |
| `<form>` | `Form(key: _formKey)` | Validates all fields at once |
| `useRef()` | `TextEditingController()` | Holds text value |
| `.map(item => <Card>)` | `ListView.builder` | Renders list items |
| `window.confirm()` | `showDialog()` | Confirmation popup |
| `useEffect([], fetch)` | `initState() + fetch` | Load data on mount |
| `className="..."` | Widget properties | No CSS, use widget params |

#### TL;DR

1. **TextEditingController** = holds form values (always dispose!)
2. **Form + GlobalKey** = validate all fields with one call
3. **context.watch** in build, **context.read** in handlers
4. **ListView.builder** = efficient list rendering
5. **showDialog** = popup confirmation

---

## Module 7: App Integration (PHASE 9 COMPLETE!)

### How main.dart Ties Everything Together

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Step 1: Flutter ready
  await dotenv.load(fileName: '.env');         // Step 2: Load secrets
  await Supabase.initialize(...);              // Step 3: Connect backend

  runApp(const MyApp());                       // Step 4: Launch!
}
```

**The app is like layers of an onion:**
```
MultiProvider (outermost - global state)
  └── MaterialApp.router (app config)
       └── GoRouter (decides which screen)
            └── Screen (UI the user sees)
                 └── Widgets (buttons, text, cards)
```

### The Complete Architecture (For Your Interview!)

```
┌──────────────────────────────────────────────────┐
│                    main.dart                       │
│         (entry point, sets up everything)          │
├──────────────────────────────────────────────────┤
│              PROVIDERS (Global State)              │
│   AuthProvider │ BlogProvider │ ThemeProvider       │
├──────────────────────────────────────────────────┤
│              ROUTER (Navigation)                   │
│   /login  /register  /  /blog/:id  /profile        │
├──────────────────────────────────────────────────┤
│              SCREENS (UI Layer)                    │
│   LoginScreen  BlogListScreen  ProfileScreen ...   │
├──────────────────────────────────────────────────┤
│              SERVICES (API Layer)                  │
│         AuthService  │  BlogService                │
├──────────────────────────────────────────────────┤
│              MODELS (Data Layer)                   │
│   UserModel  ProfileModel  BlogModel  CommentModel │
├──────────────────────────────────────────────────┤
│              SUPABASE (Backend)                    │
│         Auth  │  Database  │  Storage              │
└──────────────────────────────────────────────────┘
```

---

## Interview Quick Reference

### Why Flutter over React Native?
1. **No bridge** - compiles to native ARM code
2. **Consistent UI** - draws every pixel (no platform differences)
3. **Hot reload** - instant feedback during development
4. **Single codebase** - mobile, web, desktop

### Dart vs JavaScript Key Differences
1. **Sound null safety** - nulls are compile-time errors
2. **Type inference** - strong typing without verbosity
3. **Named parameters** - cleaner APIs
4. **Compile-time constants** - `const` for optimization

### Common Flutter Interview Questions
1. What's the difference between `StatelessWidget` and `StatefulWidget`?
2. Explain the widget lifecycle methods
3. How does `setState()` work?
4. What's the difference between `final` and `const`?
5. How do you manage state in Flutter? (Provider, Riverpod, BLoC)
6. What's the difference between `context.watch` and `context.read`?
7. How do you handle navigation in Flutter?
8. Explain async/await and Future in Dart

---

## Module 8: Interview Preparation (ASSESSMENT-SPECIFIC)

### What The Assessment Statement REALLY Means

The assessment says:
> "Flutter Assessment - Blog: **Learn and understand** Flutter, **know its language**, **its concept** and **know how to set up** flutter. Using the **same Supabase database** create a Blog using flutter with the following conditions:"

**Breaking down what they're testing:**

| Phrase | What They Want | What They'll Ask |
|--------|---------------|-----------------|
| "Learn and understand" | NOT just copy-paste. They want you to EXPLAIN your code | "Why did you use this?" "What does this do?" |
| "Know its language" | Dart fundamentals. Not expert, but solid basics | "Explain null safety" "What's final vs const?" |
| "Its concept" | Flutter architecture: widgets, state, lifecycle | "How does setState work?" "Explain the widget tree" |
| "Know how to set up" | The full setup process from scratch | "Walk me through setting up a Flutter project" |
| "Same Supabase database" | Cross-platform thinking. Reusing backend | "How does Supabase work in Flutter vs React?" |
| "Create a Blog" | Working app that does CRUD | "Show me how create/read/update/delete works" |

### The #1 Rule: DON'T MEMORIZE - UNDERSTAND

Interviewers can tell instantly if you memorized vs understood. Here's the difference:

```
MEMORIZED ANSWER (BAD):
Q: "What's a StatefulWidget?"
A: "A StatefulWidget is a widget that has mutable state and uses
    createState to create a State object that manages the state."
    (Sounds robotic, can't go deeper)

UNDERSTOOD ANSWER (GOOD):
Q: "What's a StatefulWidget?"
A: "So in my blog app, the login screen is a StatefulWidget because
    the user types in their email and password - that data changes as
    they type. I need setState() to tell Flutter 'hey, the text changed,
    redraw the screen.' But the blog card on the list? That's StatelessWidget
    because once it gets the title and content, it doesn't change."
    (Uses YOUR project as example, shows real understanding)
```

**Always tie answers back to YOUR blog app!**

---

### Part 1: "Walk Me Through Your App" (THEY WILL ASK THIS)

**How to answer (practice this!):**

> "I built a blog app using Flutter with Supabase as the backend - the same Supabase project from my React app, so both apps share the same database.
>
> **Architecture:** The app follows a layered architecture:
> - **Models** define the data shape (blog posts, users, comments)
> - **Services** handle all Supabase communication (auth, CRUD operations)
> - **Providers** manage global state using the Provider pattern with ChangeNotifier
> - **Screens** are the UI layer that consumes providers
> - **Router** handles navigation with auth guards using go_router
>
> **Features:** Users can register, log in, create/edit/delete blog posts, add comments, view other users' posts, and toggle dark mode. The router checks authentication state and redirects users to login if they're not authenticated.
>
> **The flow:** When a user creates a blog post, the screen calls the BlogProvider, which calls BlogService, which sends the data to Supabase. When it succeeds, the provider updates its state and calls notifyListeners(), and all widgets watching that provider automatically rebuild with the new data."

---

### Part 2: Setup Questions (They specifically mention "know how to set up")

**Q: "How do you set up a Flutter project from scratch?"**

> 1. Install Flutter SDK (download or `git clone` the Flutter repo)
> 2. Add Flutter to your system PATH
> 3. Run `flutter doctor` to check everything is ready (SDK, Android Studio, connected device)
> 4. Create a project: `flutter create my_app`
> 5. Navigate into the project: `cd my_app`
> 6. Add dependencies in `pubspec.yaml` (like package.json in Node)
> 7. Run `flutter pub get` to install them (like `npm install`)
> 8. Run with `flutter run` (starts on connected device/emulator)

**Q: "What's in pubspec.yaml?"**

> "It's like package.json for Flutter. It has the app name, version, Dart SDK version constraint, and dependencies. In my blog app, I have dependencies like `supabase_flutter` for the backend, `provider` for state management, `go_router` for navigation, and `flutter_dotenv` for environment variables."

**Q: "What's hot reload?"**

> "Hot reload injects updated code into the running app without losing state. So if I change a button color, I press 'r' and it instantly updates - I don't have to restart the whole app. Hot restart (capital R) DOES reset the state. This is possible because Dart uses JIT (Just-In-Time) compilation during development."

**Q: "What does `flutter doctor` check?"**

> "It checks that your Flutter SDK is installed, that you have an IDE (VS Code or Android Studio), that the Android toolchain is set up (for building Android apps), and that you have a connected device or running emulator. Any issues show up with an X and a description of how to fix them."

---

### Part 3: Dart Language Questions

**Q: "What's null safety in Dart?"**

> "In JavaScript, any variable can be null or undefined, which causes runtime crashes. In Dart, variables are non-nullable by default. If I write `String name`, it MUST have a value - Dart won't compile if there's any way it could be null. If I want it to be nullable, I use `String? name` with a question mark. This catches null errors at compile time instead of crashing at runtime.
>
> In my blog app, for example, `ProfileModel` has `String? bio` because a user might not have a bio yet, but `String id` because every profile must have an ID."

**Q: "What's the difference between `final` and `const`?"**

> "`final` means 'set once, can't change' - but the value is determined at runtime. Like `final now = DateTime.now()` - it doesn't know the time until the app runs.
>
> `const` means 'compile-time constant' - the value must be known before the app even runs. Like `const pi = 3.14`. In Flutter, `const` widgets are special because Flutter can cache them and skip rebuilding them, which improves performance.
>
> In my app, I use `const` for widgets that never change, like `const Text('Sign In')`, and `final` for controllers like `final _emailCtrl = TextEditingController()`."

**Q: "Explain `async` and `Future` in Dart."**

> "It's the same as `async/await` and `Promise` in JavaScript. A `Future` is a value that will be available later - like when I call Supabase to get blog posts, it takes time to fetch from the server. I mark the function as `async` and use `await` to wait for the result.
>
> ```dart
> Future<List<Blog>> fetchBlogs() async {
>   final data = await supabase.from('blogs').select();
>   return data.map((json) => Blog.fromJson(json)).toList();
> }
> ```
>
> `Future<List<Blog>>` is exactly like `Promise<Blog[]>` in TypeScript."

---

### Part 4: Flutter Concept Questions

**Q: "What's the difference between StatelessWidget and StatefulWidget?"**

> "StatelessWidget is for UI that doesn't change after it's built. In my app, if I had a static header that just shows text, that's stateless.
>
> StatefulWidget is for UI that changes based on user interaction. My LoginScreen is a StatefulWidget because the user types into email/password fields, toggles password visibility, and the screen shows loading/error states. These changes need `setState()` to tell Flutter to rebuild.
>
> The key thing: StatelessWidget only has `build()`. StatefulWidget has a separate State class with `initState()`, `build()`, `dispose()`, and more."

**Q: "How does `setState()` work?"**

> "When I call `setState()`, I'm telling Flutter 'hey, my data changed, please rebuild this widget.' Flutter then calls the `build()` method again, which returns the updated UI.
>
> Important: `setState()` only rebuilds THAT widget and its children, not the entire app. And I only use it for local state. For global state like the logged-in user, I use Provider and `notifyListeners()` instead."

**Q: "What's BuildContext?"**

> "BuildContext is basically the widget's address in the widget tree. It tells a widget where it sits in relation to other widgets. I use it to access things higher up in the tree - like `Theme.of(context)` to get the app's theme colors, or `context.read<AuthProvider>()` to get the auth state. Each widget gets its own context in its `build()` method."

**Q: "Explain Provider and state management."**

> "Provider is a state management solution that works like React Context but for Flutter. In my blog app, I have three providers:
>
> 1. **AuthProvider** - manages login state, user data, profile
> 2. **BlogProvider** - manages blog posts list, creating/editing/deleting posts
> 3. **ThemeProvider** - manages light/dark mode
>
> Each provider extends `ChangeNotifier`. When data changes (like a new blog post is created), the provider calls `notifyListeners()`, and every widget that's watching it automatically rebuilds.
>
> I use `context.watch()` in the `build()` method when I need live updates, and `context.read()` in button handlers when I just need to call a method once."

**Q: "What's the difference between `context.watch` and `context.read`?"**

> "`context.watch()` subscribes to the provider - the widget rebuilds whenever the provider's data changes. I use this in `build()` methods to show current data.
>
> `context.read()` reads the provider once without subscribing - no rebuilds. I use this in `onPressed` handlers to call methods like `auth.signIn()`.
>
> If I accidentally use `watch` in a button handler, it would work but waste rebuilds. If I accidentally use `read` in `build()`, the UI won't update when data changes."

---

### Part 5: Supabase Questions (They specifically mention "same Supabase database")

**Q: "How did you connect Flutter to the same Supabase project as your React app?"**

> "Since Supabase is just a backend API, any client can connect to it. I used the `supabase_flutter` package which works just like `@supabase/supabase-js` in React. The URL and anon key are the same - I put them in a `.env` file and load them with `flutter_dotenv`. The Supabase queries are almost identical between JavaScript and Dart:
>
> ```javascript
> // JavaScript
> const { data } = await supabase.from('blogs').select().eq('author_id', userId);
> ```
> ```dart
> // Dart
> final data = await supabase.from('blogs').select().eq('author_id', userId);
> ```
> Almost the same syntax!"

**Q: "How does authentication work in your app?"**

> "Supabase handles the heavy lifting. When a user signs up, Supabase creates an auth record. My app listens to `onAuthStateChange` - it's a Stream (like an event listener) that fires whenever the user logs in or out. The AuthProvider catches these events and updates the app state. The GoRouter has a `redirect` function that checks auth state on every navigation - if you're not logged in, it sends you to the login screen."

**Q: "What's Row Level Security (RLS)?"**

> "RLS is a Supabase/PostgreSQL feature that controls who can see and modify data at the database level. For example, I can set a policy that says 'users can only delete their own blog posts.' Even if someone tried to hack the API call, the database itself would block the operation. It's like a second layer of security beyond the app code."

---

### Part 6: Architecture & Design Questions

**Q: "Why did you separate Services from Providers?"**

> "Separation of concerns. Services handle HOW to talk to Supabase - the actual API calls. Providers handle WHAT state to manage and WHEN to notify the UI. This way, if I switched from Supabase to Firebase, I'd only change the Service files - the Providers and Screens wouldn't need to change.
>
> It's like a restaurant: the waiter (Provider) takes your order and brings the food, but the kitchen (Service) actually prepares it. You don't need to know how the kitchen works."

**Q: "Why Provider instead of BLoC or Riverpod?"**

> "Provider is simpler and has less boilerplate, which makes sense for a blog app of this size. BLoC (Business Logic Component) is great for very large apps where you need strict separation of events and states, but it adds complexity with streams and event classes. Riverpod is Provider's evolution with some improvements, but Provider is the officially recommended starting point and widely used. For this project's scope, Provider gives me everything I need without over-engineering."

**Q: "Walk me through the data flow when creating a blog post."**

> 1. User fills in the form on CreateBlogScreen (local state: TextEditingControllers)
> 2. Taps 'Publish' → calls `context.read<BlogProvider>().createBlog(...)`
> 3. BlogProvider sets loading state, calls `notifyListeners()`
> 4. BlogProvider calls `BlogService.createBlog(...)` which sends data to Supabase
> 5. Supabase inserts the row and returns the created blog
> 6. BlogProvider adds the new blog to its list, calls `notifyListeners()`
> 7. BlogListScreen (watching BlogProvider) automatically rebuilds with the new post
> 8. Router navigates to the blog detail screen

---

### Part 7: How to Handle "I Don't Know" Questions

They WILL ask something you don't know. Here's how to handle it:

**DON'T say:** "I don't know."

**DO say one of these:**

1. **"I haven't worked with that yet, but based on what I know..."**
   > "I haven't used BLoC, but from what I understand it uses streams for events and states, which gives more structure than Provider for complex apps."

2. **"In my project I did it this way, but I know there are other approaches..."**
   > "I used Provider for state management, but I know Riverpod improves on it with compile-safe providers and better testing support."

3. **"That's a great question - I'd approach it by..."**
   > Shows problem-solving even if you don't know the exact answer.

---

### Part 8: Quick Fire Q&A (Practice These!)

| Question | Quick Answer |
|----------|-------------|
| What's Flutter? | Google's framework for building cross-platform apps from one codebase |
| What's Dart? | Google's programming language that Flutter uses |
| Why Flutter over React Native? | Draws its own pixels (consistent UI), no bridge (faster), hot reload |
| What's a Widget? | Everything in Flutter UI is a widget - buttons, text, layouts, even the app itself |
| What's the widget tree? | Widgets nested inside widgets, like HTML DOM tree |
| What's `pubspec.yaml`? | Flutter's `package.json` - lists dependencies and app metadata |
| What's `flutter pub get`? | Flutter's `npm install` - downloads dependencies |
| What's hot reload? | Injects code changes instantly without losing app state |
| What's Material Design? | Google's design system - Flutter has built-in Material widgets |
| What's a Future? | Dart's Promise - represents a value available later |
| What's a Stream? | Like an event listener - emits multiple values over time |
| What's `mounted`? | Bool that checks if a widget is still in the tree (prevents errors after navigation) |

---

### Part 9: Red Flags to Avoid in the Interview

| Red Flag | Why It's Bad | What to Do Instead |
|----------|-------------|-------------------|
| Can't explain your own code | Shows you copy-pasted | Review every file, know what each line does |
| Only memorized definitions | Shows surface learning | Use YOUR app as examples |
| Can't modify the app live | Shows you can't code independently | Practice making small changes |
| Don't know your dependencies | Shows you didn't think about choices | Know what each package does and WHY |
| Panic at unknown questions | Shows no problem-solving skills | Say "Let me think about that..." |

---

### Part 10: Before the Interview Checklist

- [ ] Can you run the app and demonstrate all features?
- [ ] Can you explain the folder structure and why it's organized that way?
- [ ] Can you explain each of the 4 models and their fields?
- [ ] Can you walk through the auth flow (register → login → protected routes)?
- [ ] Can you explain Provider and why you used it?
- [ ] Can you explain GoRouter and the redirect (auth guard)?
- [ ] Can you explain the difference between StatefulWidget and StatelessWidget with examples from YOUR app?
- [ ] Can you explain how Supabase queries work in Dart vs JavaScript?
- [ ] Can you make a small change to the app live (like changing a validation rule)?
- [ ] Can you explain null safety with examples from YOUR models?
