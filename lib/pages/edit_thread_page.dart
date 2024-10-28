import 'package:flutter/material.dart';
import 'package:threads/model/thread.dart';
import 'package:threads/services/thread_service.dart';

class EditThreadPage extends StatefulWidget {
  final Thread thread;

  const EditThreadPage({Key? key, required this.thread}) : super(key: key);

  @override
  _EditThreadPageState createState() => _EditThreadPageState();
}

class _EditThreadPageState extends State<EditThreadPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final ThreadService _threadService = ThreadService();
  String? _image; // Store a single image URL

  @override
  void initState() {
    super.initState();
    // Populate text fields with current thread data
    _titleController.text = widget.thread.title;
    _textController.text = widget.thread.text;
    _image = widget.thread.images.isNotEmpty ? widget.thread.images.first : null; // Load the current image
  }

  Future<void> _updateThread() async {
    if (_titleController.text.isNotEmpty && _textController.text.isNotEmpty) {
      // Call the ThreadService's updateThread method with the new image URL
      await _threadService.updateThread(widget.thread.id, _imageUrlController.text);

      // Optionally, you could show a success message or handle errors
      Navigator.pop(context, true); // Return to the previous page with success
    }
  }

  Future<void> _deleteThread() async {
    final bool confirmed = await _showDeleteConfirmationDialog();
    if (confirmed) {
      await _threadService.deleteThread(widget.thread.id); // Call delete method
      Navigator.pop(context, true); // Return to the previous page after deletion
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Thread'),
          content: const Text('Are you sure you want to delete this thread?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // Return false if dialog is dismissed
  }

  void _replaceImageUrl() {
    final imageUrl = _imageUrlController.text;
    if (imageUrl.isNotEmpty) {
      setState(() {
        _image = imageUrl; // Update the image with the new URL
        _imageUrlController.clear(); // Clear the text field after replacing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Thread'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateThread,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteThread, // Call delete method on button press
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Text'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
              onSubmitted: (_) {
                _replaceImageUrl(); // Replace image on submit
              },
            ),
            // Display the current image if it exists
            if (_image != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Image.network(_image!),
              ),
          ],
        ),
      ),
    );
  }
}
