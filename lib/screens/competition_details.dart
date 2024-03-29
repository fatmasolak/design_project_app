import 'package:design_project_app/screens/admin_screens/voting_check_page.dart';
import 'package:design_project_app/widgets/calculate_results.dart';
import 'package:design_project_app/widgets/create_app_bar.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:design_project_app/constants.dart';
import 'package:design_project_app/screens/user_screens/voting_page.dart';
import 'package:design_project_app/models/competition_model.dart';
import 'package:design_project_app/widgets/join_competition.dart';

class CompetitionDetails extends StatefulWidget {
  const CompetitionDetails({
    super.key,
    required this.competition,
    required this.competitionStatus,
    required this.votingStatus,
  });

  final CompetitionModel competition;
  final String competitionStatus;
  final String votingStatus;

  @override
  State<StatefulWidget> createState() => _CompetitionDetailsState();
}

class _CompetitionDetailsState extends State<CompetitionDetails> {
  bool _isJoined = false;
  String userType = '';
  bool _isLoading = false;

  final _firebase = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    isJoined();
    _defineUserType();
  }

  void _defineUserType() async {
    final adminData = await _firestore
        .collection('admins')
        .doc(_firebase.currentUser!.uid)
        .get();

    if (adminData.exists) {
      userType = 'Admin';
    } else {
      userType = 'User';
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _joinCompetition() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinCompetition(
          competitionBanner: widget.competition.competitionBanner,
          competitionName: widget.competition.competitionName,
          competitionId: widget.competition.competitionId,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _isJoined = true;
      });
    }
  }

  void isJoined() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool isFound = false;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('joinedCompetitions')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(widget.competition.competitionId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        isFound = true;
      } else {
        print('No data found');
      }

      setState(() {
        _isJoined = isFound;
      });
    } catch (error) {
      setState(() {
        print('Something went wrong. Please try again later.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CreateAppBar(
          header: widget.competition.competitionId, isShowing: false),
      body: !_isLoading
          ? SingleChildScrollView(
              child: Column(
                children: [
                  competitionBanner(),
                  const SizedBox(height: 20),
                  competitionDescription(),
                  const SizedBox(height: 40),
                  competitionDates(),
                  const SizedBox(height: 40),
                  if (widget.competitionStatus == 'in progress' &&
                      userType == 'User')
                    joinCompetitionButton(size),
                  const SizedBox(height: 20),
                  if (widget.votingStatus == 'in progress' &&
                      userType == 'User')
                    votingButton(size),
                  if (widget.votingStatus == 'in progress' &&
                      userType == 'Admin')
                    votingCheckButton(size, context),
                  if (widget.votingStatus == 'will start soon')
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          'Voting will start on ${widget.competition.votingStartDate}',
                          style: const TextStyle(
                            color: forthColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  if (widget.votingStatus == 'completed')
                    CalculateResults(
                      competitionId: widget.competition.competitionId,
                      competitionName: widget.competition.competitionName,
                    ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Padding votingCheckButton(Size size, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: SizedBox(
        width: size.width * 0.6,
        height: size.height * 0.06,
        child: FloatingActionButton(
          heroTag: 'btn3',
          backgroundColor: forthColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29),
          ),
          onPressed: () async {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VotingCheckPage(
                  competitionId: widget.competition.competitionId,
                  competitionName: widget.competition.competitionName,
                ),
              ),
            );
          },
          child: const Text(
            'Voting Check',
            style: TextStyle(
              color: secondaryColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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
      ),
      child: SizedBox(
        width: size.width * 0.6,
        height: size.height * 0.06,
        child: FloatingActionButton(
          backgroundColor: !_isJoined ? thirdColor : forthColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29),
          ),
          onPressed: !_isJoined ? _joinCompetition : () {},
          child: Text(
            !_isJoined ? 'Join Competition' : 'Already joined',
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

  Padding votingButton(Size size) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: SizedBox(
        width: size.width * 0.6,
        height: size.height * 0.06,
        child: FloatingActionButton(
          heroTag: 'btn1',
          backgroundColor: !_isJoined ? thirdColor : forthColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29),
          ),
          onPressed: () async {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VotingPage(
                  currentCompetitionId: widget.competition.competitionId,
                ),
              ),
            );
          },
          child: const Text(
            'Vote',
            style: TextStyle(
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
