import 'package:flutter/material.dart';

class CompetitionPhotoScreen extends StatelessWidget {
  final String competitionPhoto;
  final String competitionName;

  const CompetitionPhotoScreen({
    super.key,
    required this.competitionName,
    required this.competitionPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(competitionName),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Image.network(competitionPhoto),
      ),
    );
  }
}
