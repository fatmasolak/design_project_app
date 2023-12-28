import 'package:design_project_app/constants.dart';
import 'package:design_project_app/models/competition_model.dart';
import 'package:design_project_app/widgets/join_competition.dart';
import 'package:flutter/material.dart';

class CompetitionDetails extends StatefulWidget {
  const CompetitionDetails(
      {super.key, required this.competition, required this.competitionStatus});

  final CompetitionModel competition;
  final String competitionStatus;

  @override
  State<StatefulWidget> createState() => _CompetitionDetailsState();
}

class _CompetitionDetailsState extends State<CompetitionDetails> {
  bool isJoined = false;

  void _joinCompetition() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinCompetition(
            competitionBanner: widget.competition.competitionBanner),
      ),
    );

    if (result == true) {
      setState(() {
        isJoined = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text(widget.competition.competitionId),
      ),
      body: Column(
        children: [
          competitionBanner(),
          const SizedBox(height: 20),
          competitionDescription(),
          const SizedBox(height: 40),
          competitionDates(),
          if (widget.competitionStatus == 'in progress')
            joinCompetitionButton(size),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Row competitionDates() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text(
              'Start Date',
              style: TextStyle(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.competition.competitionStartDate,
              style: const TextStyle(
                fontSize: 15,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(width: 100),
        Column(
          children: [
            const Text(
              'End Date',
              style: TextStyle(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.competition.competitionEndDate,
              style: const TextStyle(
                fontSize: 15,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column competitionDescription() {
    return const Column(
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: 20,
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus consectetur velit lectus, vitae luctus odio eleifend a. Duis nunc nisl, auctor ac ante mattis, sodales lobortis tellus. Nam nibh lacus, hendrerit et lacus ut, luctus condimentum lectus. Vivamus diam ligula, molestie vel efficitur eget, laoreet eget risus. Sed consequat purus.',
          style: TextStyle(
            fontSize: 15,
            color: primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Padding joinCompetitionButton(Size size) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 100,
      ),
      child: SizedBox(
        width: size.width * 0.6,
        height: size.height * 0.06,
        child: FloatingActionButton(
          backgroundColor: !isJoined ? thirdColor : forthColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29),
          ),
          onPressed: !isJoined ? _joinCompetition : () {},
          child: Text(
            !isJoined ? 'Join Competition' : 'Already joined',
            style: const TextStyle(
              color: secondaryColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Stack competitionBanner() {
    return Stack(
      children: [
        Image(
          image: NetworkImage(
            widget.competition.competitionBanner,
          ),
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            color: const Color.fromARGB(120, 0, 0, 0),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.competition.competitionName,
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time_sharp,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.competitionStatus,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
