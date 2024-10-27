import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:threads/model/User.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch user data by username
  Future<User?> fetchUserByUsername(String username) async {
    QuerySnapshot query = await _firestore
        .collection('users')
        .where('name', isEqualTo: username)
        .get();

    if (query.docs.isNotEmpty) {
      var userDoc = query.docs.first;
      return User.fromFirestore(userDoc);
    }
    return null; // Return null if the user is not found
  }

  // Function to create a new user
  Future<void> createUser(String username, String role) async {
    await _firestore.collection('users').add({
      'name': username,
      'role': role,
    });
  }
}