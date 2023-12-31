import 'package:flutter/material.dart';

import 'package:design_project_app/constants.dart';
import 'package:design_project_app/screens/admin_screens/admin_home_page.dart';
import 'package:design_project_app/screens/admin_screens/create_competition_page.dart';

class AdminLoggedInScreen extends StatefulWidget {
  const AdminLoggedInScreen({super.key});

  @override
  State<AdminLoggedInScreen> createState() => _AdminLoggedInScreenState();
}

class _AdminLoggedInScreenState extends State<AdminLoggedInScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminHomePageScreen(),
    const CreateCompetitionPageScreen(),
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
              Icons.add_circle,
            ),
            label: 'Create Competition',
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
