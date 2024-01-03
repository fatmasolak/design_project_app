import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_app/constants.dart';
import 'package:design_project_app/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CreateCompetitionPageScreen extends StatefulWidget {
  const CreateCompetitionPageScreen({super.key});

  @override
  State<CreateCompetitionPageScreen> createState() =>
      _CreateCompetitionPageScreenState();
}

class _CreateCompetitionPageScreenState
    extends State<CreateCompetitionPageScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isCreated = false;
  bool _isCreating = false;

  var _enteredCompetitionName = '';
  var _competitionStartDate = '';
  var _competitionEndDate = '';
  var _votingStartDate = '';
  var _votingEndDate = '';
  File _competitionBanner = File('');

  var _pickedStartDate = '';
  var _pickedEndDate = '';
  var _pickedVotingStartDate = '';
  var _pickedVotingEndDate = '';

  void _create() async {
    setState(() {
      _isCreating = true;
    });

    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _competitionStartDate = _pickedStartDate;
      _competitionEndDate = _pickedEndDate;
      _votingStartDate = _pickedVotingStartDate;
      _votingEndDate = _pickedVotingEndDate;
    });

    CollectionReference competitions =
        FirebaseFirestore.instance.collection('competitions');

    DocumentReference documentReference = await competitions.add({
      'competitionName': _enteredCompetitionName,
      'competitionEndDate': _competitionEndDate,
      'competitionStartDate': _competitionStartDate,
      'votingStartDate': _votingStartDate,
      'votingEndDate': _votingEndDate,
    });

    String competitionId = documentReference.id;

    FirebaseFirestore.instance
        .collection('competitions')
        .doc(competitionId)
        .update({
      'competitionId': competitionId,
    });

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('competition_photos')
        .child('$competitionId.jpg');

    await storageRef.putFile(_competitionBanner);

    final competitionBannerUrl = await storageRef.getDownloadURL();

    FirebaseFirestore.instance
        .collection('competitions')
        .doc(competitionId)
        .update({
      'competitionBanner': competitionBannerUrl,
    });

    setState(() {
      _isCreated = true;
      _isCreating = false;
    });
  }

  @override
  Widget build(context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Fashion'),
        actions: [
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
              color: Color.fromARGB(255, 25, 24, 26),
            ),
          ),
        ],
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
                    competitionNameField(size),
                    const SizedBox(height: 20),
                    competitionStartDateField(context, size),
                    competitionEndDateField(context, size),
                    votingStartDateField(context, size),
                    votingEndDateField(context, size),
                    UserImagePicker(
                      onPickImage: (pickedImage) {
                        _competitionBanner = pickedImage;
                      },
                      isDark: true,
                    ),
                    const SizedBox(height: 40),
                    !_isCreating
                        ? createButton(size)
                        : const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container competitionNameField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Competition Name',
          focusColor: Colors.white70,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter competition name';
          }

          return null;
        },
        onSaved: (value) {
          _enteredCompetitionName = value!;
        },
      ),
    );
  }

  Container competitionStartDateField(BuildContext context, Size size) {
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
            'Start Date',
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
                      initialDate: DateTime(2024),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2025),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          _pickedStartDate =
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
                      _pickedStartDate,
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

  Container competitionEndDateField(BuildContext context, Size size) {
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
            'End Date',
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
                      initialDate: DateTime(2024),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2025),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          _pickedEndDate =
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
                      _pickedEndDate,
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

  Container votingStartDateField(BuildContext context, Size size) {
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
            'Voting Start Date',
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
                      initialDate: DateTime(2024),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2025),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          _pickedVotingStartDate =
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
                      _pickedVotingStartDate,
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

  Container votingEndDateField(BuildContext context, Size size) {
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
            'Voting End Date',
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
                      initialDate: DateTime(2024),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2025),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          _pickedVotingEndDate =
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
                      _pickedVotingEndDate,
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

  Container createButton(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.06,
        child: ElevatedButton(
          onPressed: !_isCreated ? _create : () {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
          ),
          child: !_isCreated
              ? const Text('Create')
              : const Text('Competition Created'),
        ),
      ),
    );
  }
}
