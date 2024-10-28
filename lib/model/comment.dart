import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final String userId;
  final String threadId;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.threadId,
  });

  // Convert Firestore data to a Comment instance
  factory Comment.fromMap(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      threadId: data['threadId'] ?? '',
    );
  }

  // Convert a Comment instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userId': userId,
      'threadId': threadId,
    };
  }
}
