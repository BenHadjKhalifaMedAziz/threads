import 'package:flutter/material.dart';
import 'package:threads/services/thread_service.dart';
import 'package:threads/services/user_service.dart';
import 'package:threads/model/thread.dart';
import 'package:threads/model/user.dart';
import 'create_thread_page.dart';
import 'thread_detail_page.dart'; // Existing detail page
import 'edit_thread_page.dart'; // New edit page

class ThreadsMainPage extends StatefulWidget {
  final String username;
  final String role;
  final String userId;

  const ThreadsMainPage({
    Key? key,
    required this.username,
    required this.role,
    required this.userId,
  }) : super(key: key);

  @override
  _ThreadsMainPageState createState() => _ThreadsMainPageState();
}

class _ThreadsMainPageState extends State<ThreadsMainPage> {
  final ThreadService _threadService = ThreadService();
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _threadsWithUsers = [];

  // New variable to track the selected section
  bool _showMyThreads = false;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    List<Map<String, dynamic>> threads = await _threadService.getAllThreadsWithUser();

    _threadsWithUsers.clear(); // Clear the current list before adding updated threads
    for (var threadData in threads) {
      Thread thread = threadData['thread'];
      User? user = await _userService.fetchUserById(thread.userId);

      _threadsWithUsers.add({
        'thread': thread,
        'user': user,
      });
    }

    setState(() {}); // Trigger a rebuild with the updated threads
  }

  void _disconnect() {
    Navigator.pop(context);
  }

  void _createThread() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateThreadPage(userId: widget.userId),
      ),
    );

    if (result == true) {
      _loadThreads(); // Reload threads if a new thread was added
    }
  }

  void _viewThreadDetails(Thread thread, User user) async {
    if (_showMyThreads) {
      // If viewing "My Threads", navigate to EditThreadPage
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditThreadPage(thread: thread),
        ),
      );

      // If the result is true, reload threads
      if (result == true) {
        _loadThreads();
      }
    } else {
      // If viewing "All Threads", navigate to ThreadDetailPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ThreadDetailPage(
            thread: thread,
            username: widget.username, // Pass connected user's username
            role: widget.role,         // Pass connected user's role
            userId: widget.userId,     // Pass connected user's ID
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter threads based on the selected section
    final filteredThreads = _showMyThreads
        ? _threadsWithUsers.where((threadData) => threadData['thread'].userId == widget.userId).toList()
        : _threadsWithUsers;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.username} (${widget.role})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _disconnect,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createThread,
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle button for switching between All Threads and My Threads
          ToggleButtons(
            isSelected: [_showMyThreads, !_showMyThreads],
            onPressed: (index) {
              setState(() {
                _showMyThreads = index == 0; // If index is 0, show My Threads
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('My Threads'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('All Threads'),
              ),
            ],
          ),
          Expanded(
            child: filteredThreads.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredThreads.length,
              itemBuilder: (context, index) {
                final threadData = filteredThreads[index];
                final Thread thread = threadData['thread'];
                final User? user = threadData['user'];

                return ListTile(
                  title: Text(thread.title),
                  subtitle: Text('Created by: ${user?.name ?? "Unknown"} (${user?.role ?? "No Role"})'),
                  trailing: Text('${thread.nbLikes} Likes'),
                  onTap: () {
                    if (user != null) {
                      _viewThreadDetails(thread, user); // Pass user for detail view
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
