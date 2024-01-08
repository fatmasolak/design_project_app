import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_app/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class JoinCompetition extends StatefulWidget {
  const JoinCompetition(
      {super.key,
      required this.competitionBanner,
      required this.competitionName,
      required this.competitionId});

  final String competitionBanner;
  final String competitionName;
  final String competitionId;

  @override
  State<JoinCompetition> createState() => _JoinCompetitionState();
}

class _JoinCompetitionState extends State<JoinCompetition> {
  String _name = '';
  String _surname = '';
  String _username = '';
  String _userId = '';
  String _email = '';
  String _phone = '';
  String _birthday = '';
  File _addedPhoto = File('');
  bool _isJoined = false;
  bool _isPhotoAdded = true;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadUserInformations();
  }

  void _loadUserInformations() async {
    String name = '';
    String surname = '';
    String username = '';
    String userId = '';
    String email = '';
    String phone = '';
    String birthday = '';

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> user = doc.data() as Map<String, dynamic>;

          if (user['userId'] == FirebaseAuth.instance.currentUser!.uid) {
            name = user['name'];
            surname = user['surname'];
            username = user['username'];
            userId = user['userId'];
            email = user['email'];
            phone = user['phone'];
            birthday = user['birthday'];
          }
        }
      } else {
        print('No data found');
      }

      setState(() {
        _name = name;
        _surname = surname;
        _username = username;
        _userId = userId;
        _email = email;
        _phone = phone;
        _birthday = birthday;
      });
    } catch (e) {
      setState(() {
        print('Something went wrong. Please try again later.');
      });
    }
  }

  void _join() async {
    setState(() {
      _isJoined = true;
      _isJoining = true;
    });

    print(_isPhotoAdded);
    if (_addedPhoto.path.isEmpty) {
      setState(() {
        _isJoined = false;
        _isJoining = false;
        _isPhotoAdded = false;
        print(_isPhotoAdded);
      });
      return;
    }

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_competition_photos')
        .child(_userId)
        .child('${widget.competitionId}.jpg');

    await storageRef.putFile(_addedPhoto);

    final competitionPhotoUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('joinedCompetitions')
        .doc(_userId)
        .collection(widget.competitionId)
        .add({
      'username': _username,
      'userId': _userId,
      'competitionName': widget.competitionName,
      'competitionId': widget.competitionId,
      'competitionPhoto': competitionPhotoUrl,
      'numberOfVote': 0,
      'weight': 1,
    });

    Navigator.pop(context, _isJoined);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have joined the competition.'),
      ),
    );
  }

  void _cancel() async {
    setState(() {
      _isJoined = false;
    });

    Navigator.pop(context, _isJoined);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cancelled.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            widget.competitionBanner,
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
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                showAppBar(),
                const SizedBox(height: 30),
                showDescription(),
                const SizedBox(height: 50),
                showNameAndSurname(),
                const SizedBox(height: 10),
                showUsername(),
                const SizedBox(height: 10),
                showEmail(),
                const SizedBox(height: 10),
                showPhone(),
                const SizedBox(height: 10),
                showBirthday(),
                const SizedBox(height: 10),
                UserImagePicker(
                  onPickImage: (pickedImage) {
                    _addedPhoto = pickedImage;
                  },
                  isDark: false,
                ),
                if (!_isPhotoAdded)
                  const Text(
                    'Please add photo',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const SizedBox(height: 100),
                _isJoining
                    ? const CircularProgressIndicator(color: Colors.white)
                    : showButtons(),
              ],
            ),
          ),
          const Column(
            children: [],
          ),
        ],
      ),
    );
  }

  Row showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: Colors.white, width: 1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: _join,
          child: const Text('join'),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: _cancel,
          child: const Text(
            'cancel',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Text showBirthday() {
    return Text(
      _birthday,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    );
  }

  Text showPhone() {
    return Text(
      _phone,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    );
  }

  Text showEmail() {
    return Text(
      _email,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    );
  }

  Text showUsername() {
    return Text(
      '#$_username',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    );
  }

  Row showNameAndSurname() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _surname,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Column showDescription() {
    return Column(
      children: [
        Text(
          widget.competitionName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Please check your informations and add photo to join this competition',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  AppBar showAppBar() {
    return AppBar(
      title: const Text('Join'),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
