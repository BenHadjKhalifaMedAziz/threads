import 'package:flutter/material.dart';
import 'package:threads/model/thread.dart';

class ThreadDetailPage extends StatelessWidget {
  final Thread thread;

  const ThreadDetailPage({Key? key, required this.thread}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(thread.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created by: ${thread.userId}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Likes: ${thread.nbLikes}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              thread.text, // Full content of the thread
              style: const TextStyle(fontSize: 16),
            ),
            // If you want to show images, you can add a widget for that here
          ],
        ),
      ),
    );
  }
}
