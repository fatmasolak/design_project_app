import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:design_project_app/constants.dart';
import 'package:design_project_app/models/competition_model.dart';
import 'package:design_project_app/providers/competitions_provider.dart';
import 'package:design_project_app/screens/competition_details.dart';
import 'package:design_project_app/widgets/create_competition_card.dart';

class HomePageScreen extends ConsumerWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: secondaryColor,
            title: const Text('Fashion'),
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
            bottom: const TabBar(
              indicatorColor: forthColor,
              labelColor: forthColor,
              unselectedLabelColor: primaryColor,
              tabs: [
                Tab(text: 'Will Start Soon'),
                Tab(text: 'In Progress'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildCompetitionList(context, 'will start soon', ref),
              _buildCompetitionList(context, 'in progress', ref),
              _buildCompetitionList(context, 'completed', ref),
            ],
          ),
        ));
  }

  Widget _buildCompetitionList(
      BuildContext context, String status, WidgetRef ref) {
    final dataList = ref.watch(dataProvider);

    return dataList.when(
      data: (competition) {
        List<CompetitionModel> filteredCompetitions = competition
            .where((comp) => determineStatus(comp) == status)
            .toList();

        return ListView.builder(
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
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
}
