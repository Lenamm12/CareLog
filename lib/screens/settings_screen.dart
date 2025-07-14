import 'package:flutter/material.dart';
import 'package:carelog/services/auth_service.dart'; // Import the AuthService

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _signInWithGoogle() async {
    try {
      final userCredential = await AuthService().signInWithGoogle();

      if (userCredential != null) {
        print("Signed in with Google!");
        await AuthService().synchronizeData(); // Synchronize data after sign-in
      }
    } catch (e) {
      print(e); // Handle errors appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Settings Screen'),
            SizedBox(height: 20), // Add some spacing
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
