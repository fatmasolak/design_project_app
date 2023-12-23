import 'package:flutter/material.dart';

//The idea behind this screen  simply is to use it as a loading screen whilst
//Firebase is figuring out whether we have a token or not

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion'),
      ),
      body: const Center(
        child: Text('Loading...'),
      ),
    );
  }
}
