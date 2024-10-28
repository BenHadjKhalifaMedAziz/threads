import 'package:flutter/material.dart';
import 'package:threads/services/thread_service.dart';
import 'package:threads/services/user_service.dart';
import 'package:threads/model/thread.dart';
import 'package:threads/model/user.dart';
import 'create_thread_page.dart'; // Import the CreateThreadPage

class ThreadsMainPage extends StatefulWidget {
  final String username;
  final String role;
  final String userId; // Add userId field

  const ThreadsMainPage({
    Key? key,
    required this.username,
    required this.role,
    required this.userId, // Update constructor to accept userId
  }) : super(key: key);

  @override
  _ThreadsMainPageState createState() => _ThreadsMainPageState();
}

class _ThreadsMainPageState extends State<ThreadsMainPage> {
  final ThreadService _threadService = ThreadService();
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _threadsWithUsers = [];

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  // Load threads with user information
  Future<void> _loadThreads() async {
    List<Map<String, dynamic>> threads = await _threadService.getAllThreadsWithUser();

    for (var threadData in threads) {
      Thread thread = threadData['thread'];
      // Fetch user information based on userId
      User? user = await _userService.fetchUserById(thread.userId);

      // Log user information for debugging
      if (user != null) {
        print('Found User: ${user.name}, Role: ${user.role}');
      } else {
        print('User not found for ID: ${thread.userId}');
      }

      // Add thread and user to the list
      _threadsWithUsers.add({
        'thread': thread,
        'user': user,
      });
    }

    setState(() {});
  }

  // Navigate back to the login page
  void _disconnect() {
    Navigator.pop(context);
  }

  // Navigate to CreateThreadPage
  void _createThread() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateThreadPage(userId: widget.userId), // Pass userId to CreateThreadPage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.username} (${widget.role})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _disconnect,
          ),
          IconButton(
            icon: const Icon(Icons.add), // Button to create a thread
            onPressed: _createThread,
          ),
        ],
      ),
      body: _threadsWithUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _threadsWithUsers.length,
        itemBuilder: (context, index) {
          final threadData = _threadsWithUsers[index];
          final Thread thread = threadData['thread'];
          final User? user = threadData['user'];

          return ListTile(
            title: Text(thread.title),
            subtitle: Text('Created by: ${user?.name ?? "Unknown"} (${user?.role ?? "No Role"})'),
            trailing: Text('${thread.nbLikes} Likes'),
            onTap: () {
              // Optionally handle tap events for each thread
            },
          );
        },
      ),
    );
  }
}
