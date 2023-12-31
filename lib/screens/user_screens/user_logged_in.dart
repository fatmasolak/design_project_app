import 'package:flutter/material.dart';

import 'package:design_project_app/constants.dart';
import 'package:design_project_app/screens/user_screens/home_page.dart';
import 'package:design_project_app/screens/user_screens/joined_competition_page.dart';
import 'package:design_project_app/screens/user_screens/profile_page.dart';

class UserLoggedInScreen extends StatefulWidget {
  const UserLoggedInScreen({super.key});

  @override
  State<UserLoggedInScreen> createState() => _UserLoggedInScreenState();
}

class _UserLoggedInScreenState extends State<UserLoggedInScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageScreen(),
    const ProfilePageScreen(),
    const JoinedCompetitionPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_rounded,
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.check,
            ),
            label: 'My Competitions',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black26,
        selectedItemColor: primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
