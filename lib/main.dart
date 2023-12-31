import 'package:design_project_app/screens/admin_screens/admin_logged_in.dart';
import 'package:design_project_app/screens/splash_screen.dart';

import 'package:design_project_app/screens/user_screens/user_logged_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

import 'package:design_project_app/screens/auth.dart';
import 'package:design_project_app/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fashion',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: primaryColor,
          scaffoldBackgroundColor: secondaryColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (snapshot.hasData) {
              return FutureBuilder<String>(
                future: getUserType(),
                builder: (ctx, userTypeSnapshot) {
                  if (userTypeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SplashScreen();
                  }

                  if (userTypeSnapshot.hasData) {
                    final userType = userTypeSnapshot.data;
                    if (userType == 'User') {
                      print(userType);
                      return const UserLoggedInScreen();
                    } else {
                      print(userType);
                      return const AdminLoggedInScreen();
                    }
                  } else {
                    return const AuthScreen();
                  }
                },
              );
            }

            return const AuthScreen();
          },
        ),
      ),
    );
  }
}
