import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:design_project_app/constants.dart';
import 'package:design_project_app/models/admin_model.dart';
import 'package:design_project_app/screens/admin_screens/admin_credentials.dart';
import 'package:design_project_app/screens/user_screens/user_credentials.dart';
import 'package:design_project_app/models/user_model.dart';

final _firebase = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

Future<String> getUserType() async {
  final adminData = await _firestore
      .collection('admins')
      .doc(_firebase.currentUser!.uid)
      .get();

  if (adminData.exists) {
    return 'Admin';
  }

  return 'User';
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isAuthenticating = false;
  var _isLogin = true;
  var _isRegister = false;
  var _isSelected = false;

  var _enteredEmail = '';
  var _enteredPassword = '';

  var userType = '';

  final _firebase = FirebaseAuth.instance;

  UserModel user = UserModel(
    name: '',
    surname: '',
    username: '',
    phone: '',
    birthday: '',
    profilePhoto: File(''),
  );

  AdminModel admin = const AdminModel(
    name: '',
    surname: '',
  );

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      //to prevent sending and executing invalid data
      return;
    }

    _formKey.currentState!.save();
    //thanks to save(), special function can be assigned to all TextFormFields. write function to onSaved parameter

    try {
      setState(() {
        _isAuthenticating = true;
        _isRegister = false;
      });

      if (_isLogin) {
        final authenticatedUser = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final authenticatedUser =
            await _firebase.createUserWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);

        if (userType == 'Admin') {
          print('admin works');

          await FirebaseFirestore.instance
              .collection('admins')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'email': FirebaseAuth.instance.currentUser!.email,
            'name': admin.name,
            'surname': admin.surname,
          });
        }

        if (userType == 'User') {
          print('user works');

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_profile_photos')
              .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');

          await storageRef.putFile(user.profilePhoto);

          final profilePhotoUrl = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'email': FirebaseAuth.instance.currentUser!.email,
            'name': user.name,
            'surname': user.surname,
            'username': user.username,
            'phone': user.phone,
            'birthday': user.birthday,
            'profilePhoto': profilePhotoUrl,
          });
        }
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
        //snackbar appears at the bottom of the screen then disappears automatically
      );
      setState(() {
        _isAuthenticating = false;
        _isRegister = true;
      });
    }
  }

  List<String> imagePaths = [
    "assets/images/login_1.png",
    "assets/images/login_2.png",
    "assets/images/login_3.png",
    "assets/images/login_4.png",
    "assets/images/login_5.png",
  ];

  int currentImageIndex = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startImageSlider();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startImageSlider() {
    const Duration duration = Duration(seconds: 3);
    timer = Timer.periodic(duration, (Timer t) {
      setState(() {
        currentImageIndex = (currentImageIndex + 1) % imagePaths.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //this size provide us total height and width of our screen

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            imagePaths[currentImageIndex],
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black54,
          ),
          SingleChildScrollView(
            child: Container(
              height: size.height,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isLogin || _isRegister)
                    Column(
                      children: [
                        Text(
                          _isLogin ? 'LOGIN' : 'SIGNUP',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              emailAddressField(size),
                              passwordField(size),
                              if (_isAuthenticating)
                                const CircularProgressIndicator(
                                    color: Colors.white),
                              if (!_isAuthenticating) loginSignupButton(size),
                              if (!_isAuthenticating) createAccountField(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (!_isLogin && !_isSelected) typeSelection(size, context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column typeSelection(Size size, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            width: size.width * 0.8,
            height: size.height * 0.06,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isRegister = true;
                  _isSelected = true;
                  userType = 'User';
                });

                _awaitUserInformations(context);
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
                setState(() {
                  _isRegister = true;
                  _isSelected = true;
                  userType = 'Admin';
                });

                _awaitAdminInformations(context);
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
    );
  }

  Container emailAddressField(Size size) {
    return Container(
      width: size.width * 0.8,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(29),
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          icon: Icon(
            Icons.person,
            color: Color.fromARGB(255, 25, 24, 26),
          ),
          hintText: 'Email Address',
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        textCapitalization: TextCapitalization.none,
        validator: (value) {
          if (value == null || value.trim().isEmpty || !value.contains('@')) {
            return 'Please enter a valid email address';
          }

          return null;
        },
        onSaved: (value) {
          _enteredEmail = value!;
          //we know that value is not null because we validate it
        },
      ),
    );
  }

  Container passwordField(Size size) {
    return Container(
      width: size.width * 0.8,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(29),
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          icon: Icon(
            Icons.lock,
            color: Color.fromARGB(255, 25, 24, 26),
          ),
          hintText: 'Password',
          border: InputBorder.none,
        ),
        enableSuggestions: false,
        obscureText: true,
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty ||
              value.trim().length < 6) {
            return 'Password must be at least 6 characters long.';
          }

          return null;
        },
        onSaved: (value) {
          _enteredPassword = value!;
        },
      ),
    );
  }

  Container loginSignupButton(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.06,
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            shape: RoundedRectangleBorder(
              //to set border radius to button
              borderRadius: BorderRadius.circular(29),
            ),
            backgroundColor: const Color.fromARGB(255, 25, 24, 26),
          ),
          child: Text(
            _isLogin ? 'LOGIN' : 'SIGNUP',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  TextButton createAccountField() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
          _isRegister = false;
          _isSelected = false;
        });
      },
      child: Text(
        _isLogin ? 'Create an account' : 'I already have an acoount',
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  void _awaitAdminInformations(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCredentials(),
      ),
    );

    if (result == null) {
      setState(() {
        _isLogin = true;
        _isRegister = false;
        _isSelected = false;
      });

      return;
    }

    setState(() {
      admin = result;
    });
  }

  void _awaitUserInformations(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserCredentials(),
      ),
    );

    if (result == null) {
      setState(() {
        _isLogin = true;
        _isRegister = false;
        _isSelected = false;
      });

      return;
    }

    setState(() {
      user = result;
    });
  }
}
