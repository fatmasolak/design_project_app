import 'package:design_project_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminLoggedInScreen extends StatefulWidget {
  const AdminLoggedInScreen({super.key});

  @override
  State<AdminLoggedInScreen> createState() => _AdminLoggedInScreenState();
}

class _AdminLoggedInScreenState extends State<AdminLoggedInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Fashion'),
        actions: [
          IconButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure want to log out?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'No'),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context, 'Yes');
                    },
                    child: const Text('Yes'),
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
        child: Text('Admin page'),
      ),
    );
  }
}
