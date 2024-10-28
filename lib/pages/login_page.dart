import 'package:flutter/material.dart';
import 'threads_main_page.dart';  // Import ThreadsMainPage
import 'package:threads/model/user.dart'; // Ensure this import is correct
import 'package:threads/services/user_service.dart'; // Import UserService

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  String? errorMessage;
  final UserService _userService = UserService(); // Instantiate UserService

  // Function to fetch user data from Firestore and verify login
  Future<void> _login() async {
    final username = _usernameController.text.trim();

    // Check if the user exists
    User? user = await _userService.fetchUserByUsername(username);

    if (user != null) {
      // User exists, navigate to ThreadsMainPage with userId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ThreadsMainPage(
            username: user.name,
            role: user.role,
            userId: user.id, // Pass the user ID
          ),
        ),
      );
    } else {
      // Show error if username is not found
      setState(() {
        errorMessage = "Username not found. Try Aziz, Ahmed, or Khaled.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Enter username',
                errorText: errorMessage,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
