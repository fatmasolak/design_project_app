import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_app/constants.dart';
import 'package:design_project_app/widgets/create_app_bar.dart';
import 'package:flutter/material.dart';

class VotingCheckPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  const VotingCheckPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
  });

  @override
  State<StatefulWidget> createState() {
    return _VotingCheckPageState();
  }
}

class _VotingCheckPageState extends State<VotingCheckPage> {
  List<String> userIds = [];
  List<Map<String, dynamic>> contestantsAndVotes = [];

  bool isLoading = false;

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
              'contestantUsername': data['username'],
            });
          }
        } else {
          print('data not found');
        }
      }

      //sort the list by votes increasing to decreasing
      contestantsAndVotes
          .sort((a, b) => b.values.first.compareTo(a.values.first));

      setState(() {
        contestantsAndVotes = loadedContestantsAndVotes;
        isLoading = false;
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CreateAppBar(header: 'Votes', isShowing: false),
      body: !isLoading
          ? contestantsAndVotes.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      contestantsResult(),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    'No any votes found',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                )
          : const Center(
              child: CircularProgressIndicator(
                color: forthColor,
              ),
            ),
    );
  }

  Widget contestantsResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(contestantsAndVotes.length, (index) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            color: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Image(
                    image: NetworkImage(
                      contestantsAndVotes[index]['contestantPhoto'],
                    ),
                    height: 200,
                    width: 100,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        contestantsAndVotes[index].keys.first,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Contestant Username: ${contestantsAndVotes[index]['contestantUsername']}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                        'Number of Votes: ${contestantsAndVotes[index].values.first}'),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
