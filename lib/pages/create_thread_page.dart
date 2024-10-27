import 'package:flutter/material.dart';
import 'package:threads/model/thread.dart';
import 'package:threads/services/thread_service.dart';

class CreateThreadPage extends StatefulWidget {
  final String userId;

  const CreateThreadPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CreateThreadPageState createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<CreateThreadPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imagesController = TextEditingController(); // For image URLs
  final ThreadService _threadService = ThreadService();

  Future<void> _createThread() async {
    final title = _titleController.text.trim();
    final text = _textController.text.trim();
    final images = _imagesController.text.split(',').map((url) => url.trim()).toList(); // Splitting by commas

    if (title.isNotEmpty && text.isNotEmpty) {
      Thread newThread = Thread(
        id: '', // Initially set to empty, will be updated in Firestore
        title: title,
        text: text,
        images: images,
        userId: widget.userId,
        nbLikes: 0, // Default number of likes
      );

      await _threadService.createThread(newThread);
      Navigator.pop(context); // Go back after creating the thread
    } else {
      // Show error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Thread')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Text'),
            ),
            TextField(
              controller: _imagesController,
              decoration: InputDecoration(labelText: 'Image URLs (comma separated)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createThread,
              child: const Text('Create Thread'),
            ),
          ],
        ),
      ),
    );
  }
}
