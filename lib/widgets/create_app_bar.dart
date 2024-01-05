import 'package:design_project_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreateAppBar({
    super.key,
    required this.header,
    required this.isShowing,
  });

  final bool isShowing;
  final String header;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: primaryColor, //change your color here
      ),
      backgroundColor: secondaryColor,
      title: Text(
        header,
        style: const TextStyle(
          color: primaryColor,
        ),
      ),
      actions: [
        if (isShowing)
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
              color: primaryColor,
            ),
          ),
      ],
    );
  }
}
