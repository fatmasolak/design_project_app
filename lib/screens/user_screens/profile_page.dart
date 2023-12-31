import 'package:design_project_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePageScreen extends StatelessWidget {
  const ProfilePageScreen({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Fashion'),
        actions: [
          IconButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                backgroundColor: secondaryColor,
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: primaryColor,
                  ),
                ),
                content: const Text(
                  'Are you sure want to log out?',
                  style: TextStyle(
                    color: primaryColor,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'No'),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(
                        color: primaryColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context, 'Yes');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            icon: const Icon(
              Icons.exit_to_app,
              color: Color.fromARGB(255, 25, 24, 26),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('Profile page'),
      ),
    );
  }
}
