import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String role;

  User({required this.id, required this.name, required this.role});

  // Factory method to create a User from a Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'],
      role: data['role'],
    );
  }
}