import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:threads/model/thread.dart';
import 'package:threads/model/user.dart';
import 'package:threads/services/thread_service.dart';

class ThreadDetailPage extends StatefulWidget {
  final Thread thread;
  final User user;

  const ThreadDetailPage({
    Key? key,
    required this.thread,
    required this.user,
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
    await _threadService.toggleLike(_thread.id, widget.user.id);

    // Refresh the thread details after toggling
    DocumentSnapshot updatedThreadDoc = await FirebaseFirestore.instance
        .collection('threads')
        .doc(_thread.id)
        .get();
    setState(() {
      _thread = Thread.fromMap(
          updatedThreadDoc.data() as Map<String, dynamic>, _thread.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool userLiked = _thread.likedUsers.contains(widget.user.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(_thread.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created by: ${widget.user.name} (${widget.user.role})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Likes: ${_thread.nbLikes}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              _thread.text,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (_thread.images.isNotEmpty) ...[
              const Text(
                'Images:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _thread.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        _thread.images[index],
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _toggleLike,
              icon: Icon(userLiked ? Icons.thumb_up : Icons.thumb_up_outlined),
              label: Text(userLiked ? 'Unlike' : 'Like'),
              style: ElevatedButton.styleFrom(
                backgroundColor: userLiked ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
