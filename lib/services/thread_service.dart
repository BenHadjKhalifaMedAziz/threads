import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:threads/model/thread.dart';
import 'package:threads/model/user.dart';
import 'user_service.dart'; // Import UserService to fetch user data

class ThreadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'threads'; // Name of the Firestore collection
  final UserService _userService = UserService(); // Instantiate UserService

  // Create a new thread
  Future<void> createThread(Thread thread) async {
    try {
      DocumentReference docRef = await _firestore.collection(collection).add(thread.toMap());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print("Error creating thread: $e");
    }
  }

  // Read a thread by ID
  Future<Thread?> getThread(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(collection).doc(id).get();
      if (doc.exists) {
        return Thread.fromMap(doc.data() as Map<String, dynamic>, id);
      }
    } catch (e) {
      print("Error getting thread: $e");
    }
    return null;
  }

  // Update an existing thread
  Future<void> updateThread(Thread thread) async {
    try {
      await _firestore.collection(collection).doc(thread.id).update(thread.toMap());
    } catch (e) {
      print("Error updating thread: $e");
    }
  }

  // Delete a thread by ID
  Future<void> deleteThread(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      print("Error deleting thread: $e");
    }
  }

  // Get all threads along with the user information
  Future<List<Map<String, dynamic>>> getAllThreadsWithUser() async {
    List<Map<String, dynamic>> threadsWithUsers = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collection).get();

      for (var doc in querySnapshot.docs) {
        Thread thread = Thread.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        // Fetch user by userId associated with the thread
        User? user = await _userService.fetchUserById(thread.userId);

        // Check if the user exists
        if (user != null) {
          threadsWithUsers.add({'thread': thread, 'user': user}); // Combine thread and user data
        } else {
          print("User not found for thread ID: ${thread.id}, userId: ${thread.userId}");
          threadsWithUsers.add({'thread': thread, 'user': null}); // Add thread with null user
        }
      }
    } catch (e) {
      print("Error getting threads with users: $e");
    }
    return threadsWithUsers;
  }


  Future<void> toggleLike(String threadId, String userId) async {
    DocumentReference threadDoc = _firestore.collection(collection).doc(threadId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(threadDoc);
      if (!snapshot.exists) return;

      // Deserialize the thread from Firestore
      Thread thread = Thread.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);

      // Initialize the likedUsers list and number of likes
      List<String> likedUsers = List<String>.from(thread.likedUsers);
      int nbLikes = thread.nbLikes;

      // Check if the user has already liked the thread
      if (likedUsers.contains(userId)) {
        // User wants to unlike
        likedUsers.remove(userId);
        nbLikes -= 1;  // Decrease like count
      } else {
        // User wants to like
        likedUsers.add(userId);
        nbLikes += 1;  // Increase like count
      }

      // Update the thread document in Firestore
      transaction.update(threadDoc, {
        'likedUsers': likedUsers,
        'nbLikes': nbLikes,
      });
    });
  }




}
