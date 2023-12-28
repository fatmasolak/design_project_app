import 'package:design_project_app/models/competition_model.dart';
import 'package:design_project_app/providers/competitions_provider.dart';
import 'package:design_project_app/screens/competition_details.dart';
import 'package:design_project_app/widgets/create_competition_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomePageScreen extends ConsumerWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataList = ref.watch(dataProvider);

    return dataList.when(
      data: (competition) {
        return ListView.builder(
          itemCount: competition.length,
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
                          competition: competition[index],
                          competitionStatus:
                              determineStatus(competition[index]),
                        ),
                      ),
                    );
                  },
                  child: CreateCompetitionCard(
                      status: determineStatus(competition[index]),
                      competitions: competition,
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
