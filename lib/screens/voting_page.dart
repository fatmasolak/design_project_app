import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_app/constants.dart';
import 'package:design_project_app/models/joined_competition_model.dart';
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
    List<JoinedCompetitionModel> loadedJoinedComeptitions = [];

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
                );

                loadedJoinedComeptitions.add(competition);
              }
            }
          } else {
            print('No data found');
          }
        }
      }

      setState(() {
        joinedCompetitions = loadedJoinedComeptitions;
        joinedCompetitions.shuffle();
        isLoading = false;
        if (loadedJoinedComeptitions.length < 2) {
          isStarted = false;
        }
      });
    } catch (error) {
      setState(() {
        print('Something went wrong. Please try again later.');
        print(error);
      });
    }
  }

  void _addVote(String competitionId, String contestantId, int numberOfVote,
      String competitionPhoto) async {
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

    //this collection is used for checking current user's votes. Voted contestant is won't shown again.
    await FirebaseFirestore.instance
        .collection('votes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('$competitionId$contestantId')
        .add({
      'competitionId': competitionId,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'contestantId': contestantId,
      'competitionPhoto': competitionPhoto,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text('Vote'),
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
                          competition.competitionPhoto);

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
