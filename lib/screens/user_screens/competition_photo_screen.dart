import 'package:design_project_app/widgets/create_app_bar.dart';
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
      appBar: CreateAppBar(header: competitionName, isShowing: false),
      backgroundColor: Colors.white,
      body: Center(
        child: Image.network(competitionPhoto),
      ),
    );
  }
}
