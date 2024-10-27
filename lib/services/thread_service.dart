import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:threads/model/thread.dart';

class ThreadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'threads'; // Name of the Firestore collection

  // Create a new thread
  Future<void> createThread(Thread thread) async {
    try {
      // If id is not provided, let Firestore auto-generate it
      DocumentReference docRef = await _firestore.collection(collection).add(thread.toMap());
      // Optionally, update the thread with the generated ID
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
        return Thread.fromMap(doc.data() as Map<String, dynamic>, id); // Pass id to fromMap
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

  // Get all threads
  Future<List<Thread>> getAllThreads() async {
    List<Thread> threads = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collection).get();
      for (var doc in querySnapshot.docs) {
        threads.add(Thread.fromMap(doc.data() as Map<String, dynamic>, doc.id)); // Pass id to fromMap
      }
    } catch (e) {
      print("Error getting threads: $e");
    }
    return threads;
  }
}
