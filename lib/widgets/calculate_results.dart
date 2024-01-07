import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_app/constants.dart';
import 'package:design_project_app/screens/show_results.dart';
import 'package:flutter/material.dart';

class CalculateResults extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  const CalculateResults({
    super.key,
    required this.competitionId,
    required this.competitionName,
  });

  @override
  State<CalculateResults> createState() {
    return _CalculateResultsState();
  }
}

class _CalculateResultsState extends State<CalculateResults> {
  List<String> userIds = [];
  List<Map<String, dynamic>> contestantsAndVotes = [];
  List<Map<String, dynamic>> firstContestants = [];
  List<Map<String, dynamic>> secondContestants = [];
  List<Map<String, dynamic>> thirdContestants = [];

  bool isResultsShow = false;
  bool isLoading = false;
  bool isAddedToFirestore = false;

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

    _getNumberOfVotes();
  }

  void _getNumberOfVotes() async {
    List<Map<String, dynamic>> loadedContestantsAndVotes = [];
    List<Map<String, dynamic>> loadedFirstContestants = [];
    List<Map<String, dynamic>> loadedSecondContestants = [];
    List<Map<String, dynamic>> loadedThirdContestants = [];

    try {
      //find contestants and their votes. then create list with these data
      for (var userId in userIds) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('joinedCompetitions')
            .doc(userId)
            .collection(widget.competitionId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            loadedContestantsAndVotes.add({
              data['userId']: data['numberOfVote'],
              'contestantPhoto': data['competitionPhoto'],
              'contestantUsername': data['username']
            });
          }
        } else {
          print('data not found');
        }
      }

      setState(() {
        contestantsAndVotes = loadedContestantsAndVotes;
      });

      //sort the list by votes increasing to decreasing
      contestantsAndVotes
          .sort((a, b) => b.values.first.compareTo(a.values.first));

      //determine the first, second and third contestants
      var currentVote = -1;
      var rank = 0;
      for (var i = 0; i < loadedContestantsAndVotes.length; i++) {
        var vote = loadedContestantsAndVotes[i].values.first;
        if (vote != currentVote) {
          rank = rank + 1;
          currentVote = vote;
        }

        if (rank == 1) {
          loadedFirstContestants.add({
            loadedContestantsAndVotes[i].keys.first: vote,
            'rank': rank,
            'contestantPhoto': loadedContestantsAndVotes[i]['contestantPhoto'],
            'contestantUsername': loadedContestantsAndVotes[i]
                ['contestantUsername'],
          });
        } else if (rank == 2) {
          loadedSecondContestants.add({
            loadedContestantsAndVotes[i].keys.first: vote,
            'rank': rank,
            'contestantPhoto': loadedContestantsAndVotes[i]['contestantPhoto'],
            'contestantUsername': loadedContestantsAndVotes[i]
                ['contestantUsername'],
          });
        } else if (rank == 3) {
          loadedThirdContestants.add({
            loadedContestantsAndVotes[i].keys.first: vote,
            'rank': rank,
            'contestantPhoto': loadedContestantsAndVotes[i]['contestantPhoto'],
            'contestantUsername': loadedContestantsAndVotes[i]
                ['contestantUsername'],
          });
        }

        if (!isAddedToFirestore) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('results')
              .doc(widget.competitionId)
              .collection(loadedContestantsAndVotes[i].keys.first)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            print('already added');

            setState(() {
              isAddedToFirestore = true;
            });
          }

          if (querySnapshot.docs.isEmpty) {
            print('not added yet');

            await FirebaseFirestore.instance
                .collection('results')
                .doc(widget.competitionId)
                .collection(loadedContestantsAndVotes[i].keys.first)
                .doc('result${widget.competitionId}')
                .set({
              'rank': rank,
              'competitionId': widget.competitionId,
              'competitionName': widget.competitionName,
              'numberOfVotes': vote,
              'contestantId': loadedContestantsAndVotes[i].keys.first,
              'contestantPhoto': loadedContestantsAndVotes[i]
                  ['contestantPhoto'],
              'contestantUsername': loadedContestantsAndVotes[i]
                  ['contestantUsername'],
            });
          }
        }
      }

      setState(() {
        firstContestants = loadedFirstContestants;
        secondContestants = loadedSecondContestants;
        thirdContestants = loadedThirdContestants;
        isLoading = false;
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.6,
              height: MediaQuery.sizeOf(context).height * 0.06,
              child: FloatingActionButton(
                heroTag: 'btn2',
                backgroundColor: forthColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(29),
                ),
                onPressed: () async {
                  //_getNumberOfVotes();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowResultsScreen(
                        contestantsAndVotes: contestantsAndVotes,
                        firstContestants: firstContestants,
                        secondContestants: secondContestants,
                        thirdContestants: thirdContestants,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Show Results',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(
              color: forthColor,
            ),
          );
  }
}
