import 'package:design_project_app/constants.dart';
import 'package:design_project_app/widgets/create_app_bar.dart';
import 'package:flutter/material.dart';

class ShowResultsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> contestantsAndVotes;
  final List<Map<String, dynamic>> firstContestants;
  final List<Map<String, dynamic>> secondContestants;
  final List<Map<String, dynamic>> thirdContestants;

  const ShowResultsScreen({
    super.key,
    required this.contestantsAndVotes,
    required this.firstContestants,
    required this.secondContestants,
    required this.thirdContestants,
  });

  @override
  State<ShowResultsScreen> createState() {
    return _ShowResultsScreenState();
  }
}

class _ShowResultsScreenState extends State<ShowResultsScreen> {
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    _concatenateResults();
  }

  void _concatenateResults() {
    List<Map<String, dynamic>> allResults = [];

    allResults.addAll(widget.firstContestants);
    allResults.addAll(widget.secondContestants);
    allResults.addAll(widget.thirdContestants);

    setState(() {
      results = allResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CreateAppBar(header: 'Results', isShowing: false),
      body: widget.contestantsAndVotes.isNotEmpty
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
                'No any results found',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
    );
  }

  ListView contestantsResult() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (context, index) {
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
                      results[index]['contestantPhoto'],
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
                    Text(
                      (results[index]['rank'] == 1)
                          ? 'First Contestant'
                          : (results[index]['rank'] == 2)
                              ? 'Second Contestant'
                              : 'Third Contestant',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Contestant Username: ${results[index]['contestantUsername']}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Number of Votes: ${results[index].values.first}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
