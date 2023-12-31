import 'package:design_project_app/constants.dart';
import 'package:flutter/material.dart';

import 'package:design_project_app/models/admin_model.dart';

class AdminCredentials extends StatefulWidget {
  const AdminCredentials({super.key});

  @override
  State<AdminCredentials> createState() {
    return _AdminCredentialsState();
  }
}

class _AdminCredentialsState extends State<AdminCredentials> {
  final _formKey = GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredSurname = '';

  AdminModel admin = const AdminModel(
    name: '',
    surname: '',
  );

  void _save() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      admin = AdminModel(
        name: _enteredName,
        surname: _enteredSurname,
      );

      Navigator.pop(context, admin);
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
            backgroundColor: const Color.fromARGB(255, 25, 24, 26),
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
