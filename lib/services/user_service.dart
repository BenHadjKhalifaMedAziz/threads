import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:threads/model/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch a user by username
  Future<User?> fetchUserByUsername(String username) async {
    QuerySnapshot querySnapshot = await _firestore.collection('users')
        .where('name', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return User.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  // Fetch a user by ID
  Future<User?> fetchUserById(String id) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();

    if (doc.exists) {
      return User.fromFirestore(doc);
    }
    return null;
  }
}
