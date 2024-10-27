import 'package:flutter/material.dart';
import 'create_thread_page.dart'; // Import the new page
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:threads/model/thread.dart'; // Ensure your Thread model is defined
import 'thread_detail_page.dart'; // Import the detail page

class ThreadsMainPage extends StatefulWidget {
  final String username;
  final String role;

  const ThreadsMainPage({Key? key, required this.username, required this.role}) : super(key: key);

  @override
  _ThreadsMainPageState createState() => _ThreadsMainPageState();
}

class _ThreadsMainPageState extends State<ThreadsMainPage> {
  // Fetch threads from Firestore
  Stream<List<Thread>> _fetchThreads() {
    return FirebaseFirestore.instance
        .collection('threads') // Replace with your Firestore collection name
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Thread.fromMap(doc.data(), doc.id)) // Ensure your Thread model has a fromMap method
        .toList());
  }

  void _logout(BuildContext context) {
    // Add your logout logic here (e.g., navigating back to the login page)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.role,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Disconnect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Thread>>(
        stream: _fetchThreads(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No threads available.'));
          }

          final threads = snapshot.data!;

          return ListView.builder(
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return ListTile(
                title: Text(thread.title),
                subtitle: Text('Created by: ${thread.userId} | Likes: ${thread.nbLikes}'),
                onTap: () {
                  // Navigate to the thread detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThreadDetailPage(thread: thread), // Pass the selected thread
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateThreadPage(userId: widget.username),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
