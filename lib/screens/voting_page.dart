import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_app/constants.dart';
import 'package:design_project_app/models/joined_competition_model.dart';
import 'package:design_project_app/widgets/create_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key, required this.currentCompetitionId});

  final String currentCompetitionId;

  @override
  State<VotingPage> createState() {
    return _VotingPageState();
  }
}

class _VotingPageState extends State<VotingPage> {
  List<String> userIds = [];
  List<JoinedCompetitionModel> joinedCompetitions = [];
  bool isLoading = false;
  bool isStarted = true;

  @override
  void initState() {
    super.initState();
    _loadUserIds();
  }

  void _loadUserIds() async {
    List<String> loadedUserIds = [];

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          loadedUserIds.add(data['userId']);
        }
      } else {
        print('No data found');
      }

      setState(() {
        userIds = loadedUserIds;
      });
    } catch (error) {
      setState(() {
        print('Something went wrong. Please try again later.');
      });
    }

    _loadJoinedCompetitionsAndUsers();
  }

  void _loadJoinedCompetitionsAndUsers() async {
    List<JoinedCompetitionModel> loadedJoinedCompetitions = [];

    try {
      for (var userId in userIds) {
        if (userId != FirebaseAuth.instance.currentUser!.uid) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('joinedCompetitions')
              .doc(userId)
              .collection(widget.currentCompetitionId)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            for (var doc in querySnapshot.docs) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              QuerySnapshot querySnapshotVote = await FirebaseFirestore.instance
                  .collection('votes')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('${data['competitionId']}${data['userId']}')
                  .get();

              if (querySnapshotVote.docs.isEmpty) {
                JoinedCompetitionModel competition = JoinedCompetitionModel(
                  username: data['username'],
                  userId: data['userId'],
                  competitionName: data['competitionName'],
                  competitionId: data['competitionId'],
                  competitionPhoto: data['competitionPhoto'],
                  numberOfVote: data['numberOfVote'],
                  weight: data['weight'],
                );

                loadedJoinedCompetitions.add(competition);
              }
            }
          } else {
            print('No data found');
          }
        }
      }

      if (loadedJoinedCompetitions.length < 2) {
        setState(() {
          isLoading = false;
          isStarted = false;
        });
      } else {
        //sort contestants from high weight to low weight
        loadedJoinedCompetitions.sort((a, b) => b.weight.compareTo(a.weight));

        for (var cont in loadedJoinedCompetitions) {
          print('${cont.username} - ${cont.weight}');
        }

        int totalWeight = 0;
        for (var contestant in loadedJoinedCompetitions) {
          totalWeight += contestant.weight;
        }

        List<JoinedCompetitionModel> contestants = [];
        int randomNumber = Random().nextInt(totalWeight);
        int sum = 0;
        int weight = 0;
        String documentID = '';

        for (var contestant in loadedJoinedCompetitions) {
          sum += contestant.weight;

          print('random: $randomNumber - sum: $sum');

          if (randomNumber < sum) {
            contestants.add(contestant);
          }
        }

        for (var contestant in contestants) {
          print('${contestant.username} - ${contestant.weight}');
        }

        if (contestants.length < 2) {
          loadedJoinedCompetitions.sort((a, b) => a.weight.compareTo(b.weight));

          for (var i = 0; i < 2; i++) {
            //update the weight of contestants that will be shown
            weight = loadedJoinedCompetitions[i].weight;
            weight++;

            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection('joinedCompetitions')
                .doc(loadedJoinedCompetitions[i].userId)
                .collection(widget.currentCompetitionId)
                .get();

            for (DocumentSnapshot document in querySnapshot.docs) {
              documentID = document.id;
            }

            await FirebaseFirestore.instance
                .collection('joinedCompetitions')
                .doc(loadedJoinedCompetitions[i].userId)
                .collection(widget.currentCompetitionId)
                .doc(documentID)
                .update({'weight': weight});
          }

          setState(() {
            joinedCompetitions = loadedJoinedCompetitions;
            isLoading = false;
            if (loadedJoinedCompetitions.length < 2) {
              isStarted = false;
            }
          });
        } else {
          //sort contestants from low weight to high weight to choose users that has low weight
          contestants.sort((a, b) => a.weight.compareTo(b.weight));

          for (var i = 0; i < 2; i++) {
            //update the weight of contestants that will be shown
            weight = contestants[i].weight;
            weight++;

            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection('joinedCompetitions')
                .doc(contestants[i].userId)
                .collection(widget.currentCompetitionId)
                .get();

            for (DocumentSnapshot document in querySnapshot.docs) {
              documentID = document.id;
            }

            await FirebaseFirestore.instance
                .collection('joinedCompetitions')
                .doc(contestants[i].userId)
                .collection(widget.currentCompetitionId)
                .doc(documentID)
                .update({'weight': weight});
          }

          setState(() {
            joinedCompetitions = contestants;
            isLoading = false;
            if (contestants.length < 2) {
              isStarted = false;
            }
          });
        }
      }
    } catch (error) {
      setState(() {
        print('Something went wrong. Please try again later.');
        print(error);
      });
    }
  }

  void _addVote(
      String competitionId,
      String contestantId,
      int numberOfVote,
      String competitionPhoto,
      String competitionName,
      String contestantUsername) async {
    String docId = '';

    //to fetch voted contestant doc id
    await FirebaseFirestore.instance
        .collection('joinedCompetitions')
        .doc(contestantId)
        .collection(competitionId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        docId = doc.id;
      }
    }).catchError((error) {
      print('Hata: $error');
    });

    numberOfVote++;

    await FirebaseFirestore.instance
        .collection('joinedCompetitions')
        .doc(contestantId)
        .collection(competitionId)
        .doc(docId)
        .update(
      {
        'numberOfVote': numberOfVote,
      },
    );

    //this collection is used for checking current user's votes. Voted contestant is not shown again.
    await FirebaseFirestore.instance
        .collection('votes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('$competitionId$contestantId')
        .add({
      'competitionId': competitionId,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'contestantId': contestantId,
      'competitionPhoto': competitionPhoto,
      'competitionName': competitionName,
      'contestantUsername': contestantUsername,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CreateAppBar(header: 'Vote', isShowing: false),
      body: !isLoading
          ? isStarted
              ? Row(
                  children: [
                    _buildContestantTile(joinedCompetitions[0]),
                    _buildContestantTile(joinedCompetitions[1]),
                  ],
                )
              : const Center(
                  child: Text('Voting has not started yet'),
                )
          : const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
    );
  }

  Widget _buildContestantTile(JoinedCompetitionModel competition) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            competition.competitionPhoto,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(140, 0, 0, 0),
                      foregroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(29),
                      ),
                    ),
                    onPressed: () {
                      _addVote(
                        competition.competitionId,
                        competition.userId,
                        competition.numberOfVote,
                        competition.competitionPhoto,
                        competition.competitionName,
                        competition.username,
                      );

                      setState(() {
                        _loadUserIds();
                      });
                    },
                    child: const Text(
                      'Vote',
                      style: TextStyle(
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
