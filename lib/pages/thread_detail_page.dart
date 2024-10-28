import 'package:flutter/material.dart';
import 'package:threads/model/thread.dart';
import 'package:threads/services/thread_service.dart';

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

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
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
            Text('Created by: ${_thread.userId}'), // Display creator ID
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
            const SizedBox(height: 20), // Spacer before the connected user info
            Divider(), // Optional divider for better layout
            const SizedBox(height: 10), // Spacer
            // Display connected user details at the bottom
            Text(
              'User ID: ${widget.userId}', // Display connected user's ID
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
