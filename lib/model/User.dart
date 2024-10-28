import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure this line is present
class User {
  final String id;
  final String name;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.role,
  });

  // Factory constructor to create a User from Firestore DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id, // Use the document ID
      name: data['name'] ?? '',
      role: data['role'] ?? 'User', // Default role if not specified
    );
  }

  // Convert User instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
    };
  }
}
