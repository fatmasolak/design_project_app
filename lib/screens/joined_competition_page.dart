import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:design_project_app/constants.dart';
import 'package:design_project_app/models/competition_model.dart';
import 'package:design_project_app/models/joined_competition_model.dart';
import 'package:design_project_app/providers/competitions_provider.dart';
import 'package:design_project_app/screens/competition_details.dart';
import 'package:design_project_app/widgets/create_competition_card.dart';

class JoinedCompetitionPageScreen extends ConsumerStatefulWidget {
  const JoinedCompetitionPageScreen({super.key});

  @override
  ConsumerState<JoinedCompetitionPageScreen> createState() =>
      _JoinedCompetitionPageScreenState();
}

class _JoinedCompetitionPageScreenState
    extends ConsumerState<JoinedCompetitionPageScreen> {
  List<String> competitionIds = [];
  List<JoinedCompetitionModel> myCompetitions = [];
  List<String> myCompetitionIds = [];
  bool isLoading = false;
  bool _showNoCompetitionText = false;

  @override
  void initState() {
    super.initState();
    _loadCompetitionIds();
    _startShowTextTimer();
  }

  void _startShowTextTimer() {
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showNoCompetitionText = true;
      });
    });
  }

  void _loadCompetitionIds() async {
    List<String> loadedCompetitionIds = [];

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('competitions').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          loadedCompetitionIds.add(data['competitionId']);
        }
      } else {
        print('No data found');
      }

      setState(() {
        competitionIds = loadedCompetitionIds;
      });
    } catch (error) {
      setState(() {
        print('Something went wrong. Please try again later.');
      });
    }

    print(competitionIds);

    _loadMyCompetitions(competitionIds);
  }

  void _loadMyCompetitions(List competitionIds) async {
    List<JoinedCompetitionModel> loadedJoinedCompetitions = [];
    List<String> loadedJoinedCompetitionsIds = [];

    try {
      for (var id in competitionIds) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('joinedCompetitions')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection(id)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            JoinedCompetitionModel competition = JoinedCompetitionModel(
              username: data['username'],
              userId: data['userId'],
              competitionName: data['competitionName'],
              competitionId: data['competitionId'],
              competitionPhoto: data['competitionPhoto'],
              numberOfVote: data['numberOfVote'],
            );

            loadedJoinedCompetitions.add(competition);
            loadedJoinedCompetitionsIds.add(competition.competitionId);
          }
        } else {
          print('No data found');
        }
      }

      setState(() {
        myCompetitions = loadedJoinedCompetitions;
        myCompetitionIds = loadedJoinedCompetitionsIds;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        print('Something went wrong. Please try again later.');
        print(error);
      });
    }

    print(myCompetitions);
  }

  @override
  Widget build(context) {
    final dataList = ref.watch(dataProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Fashion'),
        actions: [
          IconButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure want to log out?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'No'),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context, 'Yes');
                    },
                    child: const Text('Yes'),
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
      body: dataList.when(
        data: (competition) {
          List<CompetitionModel> filteredCompetitions =
              competition.where((comp) => determineIsJoined(comp)).toList();

          Widget content = ListView.builder(
            shrinkWrap: true,
            itemCount: filteredCompetitions.length,
            itemBuilder: (context, index) => Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompetitionDetails(
                            competition: filteredCompetitions[index],
                            competitionStatus:
                                determineStatus(filteredCompetitions[index]),
                          ),
                        ),
                      );
                    },
                    child: CreateCompetitionCard(
                        status: determineStatus(filteredCompetitions[index]),
                        competitions: filteredCompetitions,
                        index: index),
                  ),
                ),
              ),
            ),
          );

          if (isLoading) {
            content = const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (_showNoCompetitionText && filteredCompetitions.isEmpty) {
            content = const Center(
              child: Text('No any joined competitions'),
            );
          }

          return content;
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  String determineStatus(CompetitionModel competition) {
    DateFormat format = DateFormat('dd/MM/yyyy');

    DateTime startDate = format.parse(competition.competitionStartDate);
    DateTime endDate = format.parse(competition.competitionEndDate);

    DateTime now = DateTime.now();

    String status = "";

    if (startDate.isAfter(now)) {
      status = "will start soon";
    }
    if (endDate.isBefore(now)) {
      status = "completed";
    }
    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      status = "in progress";
    }

    return status;
  }

  bool determineIsJoined(CompetitionModel competition) {
    bool isJoined = false;

    for (var id in myCompetitionIds) {
      if (competition.competitionId == id) {
        isJoined = true;
      }
    }

    return isJoined;
  }
}
