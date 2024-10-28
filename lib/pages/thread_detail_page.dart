import 'package:flutter/material.dart';
import 'package:threads/model/thread.dart';
import 'package:threads/model/comment.dart';
import 'package:threads/services/thread_service.dart';
import 'package:threads/services/comment_service.dart';
import 'package:threads/services/user_service.dart';

class ThreadDetailPage extends StatefulWidget {
  final Thread thread;
  final String username; // Currently logged-in user's username
  final String role;     // Currently logged-in user's role
  final String userId;   // Currently logged-in user's ID

  const ThreadDetailPage({
    Key? key,
    required this.thread,
    required this.username,
    required this.role,
    required this.userId,
  }) : super(key: key);

  @override
  _ThreadDetailPageState createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> {
  late Thread _thread;
  final ThreadService _threadService = ThreadService();
  final CommentService _commentService = CommentService();
  final UserService _userService = UserService();
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  Map<String, String> _usernames = {}; // Map to store userId to username
  String? _editingCommentId; // Track the comment being edited
  String _editingText = ''; // Text for the editing comment

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
    _loadComments(); // Load comments when the page initializes
  }

  Future<void> _loadComments() async {
    List<Comment> comments = await _commentService.getCommentsForThread(_thread.id, widget.userId);
    _comments = comments;

    // Fetch usernames for each comment
    for (var comment in comments) {
      String? username = await _userService.fetchUsernameById(comment.userId);
      if (username != null) {
        _usernames[comment.userId] = username; // Store username in the map
      }
    }

    setState(() {}); // Update the UI
  }

  Future<void> _toggleLike() async {
    await _threadService.toggleLike(_thread.id, widget.userId); // Call the existing toggleLike method

    // Reload the thread to get updated likes
    final updatedThread = await _threadService.getThread(_thread.id);
    if (updatedThread != null) {
      setState(() {
        _thread = updatedThread; // Update the local thread object with new data
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final newComment = Comment(
        id: '', // ID will be generated by Firestore
        text: _commentController.text,
        userId: widget.userId,
        threadId: _thread.id,
      );

      await _commentService.createComment(newComment);
      _commentController.clear(); // Clear the text field
      _loadComments(); // Reload comments after adding
    }
  }

  Future<void> _deleteComment(String commentId) async {
    await _commentService.deleteComment(commentId); // Call the delete method
    _loadComments(); // Reload comments after deletion
  }

  void _editComment(String commentId, String currentText) {
    setState(() {
      _editingCommentId = commentId; // Set the comment ID to edit
      _editingText = currentText; // Set the current text for editing
    });
    _commentController.text = currentText; // Populate the text field with current text
  }

  Future<void> _updateComment() async {
    if (_editingCommentId != null && _commentController.text.isNotEmpty) {
      final updatedComment = Comment(
        id: _editingCommentId!,
        text: _commentController.text,
        userId: widget.userId,
        threadId: _thread.id,
      );

      await _commentService.updateComment(updatedComment); // Update the comment
      _commentController.clear(); // Clear the text field
      _editingCommentId = null; // Reset the editing comment ID
      _editingText = ''; // Reset the editing text
      _loadComments(); // Reload comments after updating
    }
  }

  Future<String?> _fetchUsernameById(String userId) async {
    return await _userService.fetchUsernameById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_thread.title), // Display thread title in the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String?>(
              future: _fetchUsernameById(_thread.userId),
              builder: (context, snapshot) {
                String creatorUsername = snapshot.connectionState == ConnectionState.waiting
                    ? 'Loading...' // Show loading indicator
                    : snapshot.hasData
                    ? snapshot.data!
                    : _thread.userId; // Fallback to userId if username not found
                return Text('Created by: $creatorUsername'); // Display creator's username
              },
            ),
            const SizedBox(height: 10),
            Text(_thread.text),
            const SizedBox(height: 10),
            // Display images if available
            if (_thread.images.isNotEmpty)
              Column(
                children: _thread.images.map((url) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Image.network(url),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_thread.nbLikes} Likes'),
                IconButton(
                  icon: Icon(
                    _thread.likedUsers.contains(widget.userId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _thread.likedUsers.contains(widget.userId)
                        ? Colors.red
                        : null,
                  ),
                  onPressed: _toggleLike,
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacer before comments section
            Divider(), // Optional divider for better layout
            const SizedBox(height: 10), // Spacer

            // Comments section
            Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return ListTile(
                    title: Text(comment.text),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('By: ${_usernames[comment.userId] ?? comment.userId}'), // Display username instead of userId
                        if (comment.userId == widget.userId) // Check if the current user is the comment's owner
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editComment(comment.id, comment.text),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteComment(comment.id),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: _editingCommentId != null ? 'Edit Comment' : 'Add Comment',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _editingCommentId != null ? _updateComment : _addComment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
