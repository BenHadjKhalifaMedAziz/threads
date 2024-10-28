import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:threads/model/comment.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'comments'; // Name of the Firestore collection

  // Create a new comment
  Future<void> createComment(Comment comment) async {
    try {
      await _firestore.collection(collection).add(comment.toMap());
    } catch (e) {
      print("Error creating comment: $e");
    }
  }

  // Read comments for a specific thread and sort them
  Future<List<Comment>> getCommentsForThread(String threadId, String currentUserId) async {
    List<Comment> comments = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collection)
          .where('threadId', isEqualTo: threadId)
          .get();

      for (var doc in querySnapshot.docs) {
        comments.add(Comment.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      }

      // Sort comments: first by whether the user is the current user, then by the document ID (or any other property you prefer)
      comments.sort((a, b) {
        if (a.userId == currentUserId && b.userId != currentUserId) {
          return -1; // a comes before b
        } else if (b.userId == currentUserId && a.userId != currentUserId) {
          return 1; // b comes before a
        } else {
          return 0; // maintain original order for others
        }
      });

    } catch (e) {
      print("Error getting comments: $e");
    }
    return comments;
  }

  // Delete a comment by ID
  Future<void> deleteComment(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      print("Error deleting comment: $e");
    }
  }

  // Update a comment
  Future<void> updateComment(Comment comment) async {
    try {
      await _firestore.collection(collection).doc(comment.id).update({
        'text': comment.text,
        // Add other fields to update if necessary
      });
    } catch (e) {
      print("Error updating comment: $e");
    }
  }
}
