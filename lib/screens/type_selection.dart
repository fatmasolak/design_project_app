import 'dart:ui';

import 'package:design_project_app/constants.dart';
import 'package:flutter/material.dart';

class TypeSelectionScreen extends StatelessWidget {
  const TypeSelectionScreen({super.key});

  @override
  Widget build(context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            "assets/images/login_4.png",
            fit: BoxFit.cover,
          ),
          Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.5,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    width: size.width * 0.8,
                    height: size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'User');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: thirdColor,
                      ),
                      child: const Text(
                        'User',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    width: size.width * 0.8,
                    height: size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'Admin');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: forthColor,
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
