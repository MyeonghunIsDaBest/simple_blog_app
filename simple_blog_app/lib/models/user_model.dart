// ============================================================================
// USER MODEL
// ============================================================================
//
// WHAT IS A MODEL?
// A model is a "blueprint" for your data.
//
// Think of it like a form:
//   Name: ________
//   Email: ________
//
// The model says: "A User MUST have an id, email, and createdAt"
//
// WITHOUT model: data is a messy Map {'id': '123', 'email': '...'}
//                You can typo field names and get no warning!
//
// WITH model:    data is user.id, user.email
//                Dart warns you if you use wrong field names!
//
// JAVASCRIPT/TYPESCRIPT EQUIVALENT:
//
// interface User {
//   id: string;
//   email: string;
//   createdAt: Date;
// }
//
// ============================================================================

class UserModel {
  // The data this model holds
  // 'final' = can't change after creation (like const in JS)
  final String id;
  final String email;
  final DateTime createdAt;

  // Constructor - how you create a UserModel
  // {required this.id} means: you MUST provide id, and it auto-assigns
  UserModel({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  // fromJson - turns API data (Map) into a UserModel object
  //
  // Supabase sends: {'id': 'abc', 'email': 'john@mail.com', 'created_at': '...'}
  // This turns it into: UserModel(id: 'abc', email: 'john@mail.com', ...)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // toJson - turns UserModel back into a Map (to send to Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
