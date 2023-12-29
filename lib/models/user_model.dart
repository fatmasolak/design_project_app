import 'dart:io';

//this class is used to add new user to firestore

class UserModel {
  const UserModel({
    required this.name,
    required this.surname,
    required this.username,
    required this.phone,
    required this.birthday,
    required this.profilePhoto,
  });

  final String name;
  final String surname;
  final String username;
  final String phone;
  final String birthday;
  final File profilePhoto;
}
