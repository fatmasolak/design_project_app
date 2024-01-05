import 'package:design_project_app/constants.dart';
import 'package:flutter/material.dart';

class CreateCompetitionPhotoCard extends StatefulWidget {
  const CreateCompetitionPhotoCard({
    super.key,
    required this.competitionName,
    required this.competitionPhoto,
  });

  final String competitionName;
  final String competitionPhoto;

  @override
  State<StatefulWidget> createState() {
    return _CreateCompetitionPhotoCardState();
  }
}

class _CreateCompetitionPhotoCardState
    extends State<CreateCompetitionPhotoCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 200,
      child: Card(
        color: secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Stack(
          children: [
            Image(
              image: NetworkImage(
                widget.competitionPhoto,
              ),
              height: 400,
              width: 200,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              left: 8,
              child: Text(
                widget.competitionName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
