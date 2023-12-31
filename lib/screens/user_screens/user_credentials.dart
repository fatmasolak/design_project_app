import 'dart:io';
import 'package:design_project_app/constants.dart';
import 'package:flutter/material.dart';

import 'package:design_project_app/models/user_model.dart';
import 'package:design_project_app/widgets/user_image_picker.dart';

class UserCredentials extends StatefulWidget {
  const UserCredentials({super.key});

  @override
  State<UserCredentials> createState() {
    return _UserCredentialsState();
  }
}

class _UserCredentialsState extends State<UserCredentials> {
  final _formKey = GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredSurname = '';
  var _enteredUsername = '';
  var _enteredPhone = '';
  var _birthday = '';
  var _pickedDate = '';
  File _profilePhoto = File('');

  UserModel user = UserModel(
    name: '',
    surname: '',
    username: '',
    phone: '',
    birthday: '',
    profilePhoto: File(''),
  );

  void _save() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _birthday = _pickedDate;

      user = UserModel(
        name: _enteredName,
        surname: _enteredSurname,
        username: _enteredUsername,
        phone: _enteredPhone,
        birthday: _birthday,
        profilePhoto: _profilePhoto,
      );

      Navigator.pop(context, user);
    });
  }

  void _cancel() async {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: secondaryColor,
        title: const Center(
          child: Text(
            'Enter Your Information',
            style: TextStyle(
              color: primaryColor,
            ),
          ),
        ),
      ),
      body: Container(
        height: size.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    nameField(size),
                    surnameField(size),
                    usernameField(size),
                    phoneField(size),
                    const SizedBox(height: 20),
                    birthdayField(context, size),
                    UserImagePicker(
                      onPickImage: (pickedImage) {
                        _profilePhoto = pickedImage;
                      },
                      isDark: true,
                    ),
                    const SizedBox(height: 40),
                    saveButton(size),
                    cancelButton(size),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container nameField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Name',
          focusColor: Colors.white70,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your name';
          }

          return null;
        },
        onSaved: (value) {
          _enteredName = value!;
          //we know that value is not null because we validate it
        },
      ),
    );
  }

  Container surnameField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Surname',
          focusColor: Colors.white70,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your surname';
          }

          return null;
        },
        onSaved: (value) {
          _enteredSurname = value!;
        },
      ),
    );
  }

  Container usernameField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Username',
          focusColor: Colors.white70,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your username';
          }

          return null;
        },
        onSaved: (value) {
          _enteredUsername = value!;
        },
      ),
    );
  }

  Container phoneField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Phone',
          focusColor: Colors.white70,
        ),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your phone number';
          }

          return null;
        },
        onSaved: (value) {
          _enteredPhone = value!;
        },
      ),
    );
  }

  Container birthdayField(BuildContext context, Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: Column(
        children: [
          const Text(
            'Birthday',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color.fromARGB(255, 25, 24, 26),
              fontSize: 14.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 90,
              vertical: 5,
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime(2006),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          _pickedDate =
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                        });
                      }
                    });
                  },
                  child: const Text(
                    'Pick Date',
                    style: TextStyle(
                      color: Color.fromARGB(255, 25, 24, 26),
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      _pickedDate,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 25, 24, 26),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container saveButton(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.06,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
          ),
          child: const Text('Save'),
        ),
      ),
    );
  }

  Container cancelButton(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.06,
        child: TextButton(
          onPressed: _cancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
          ),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
