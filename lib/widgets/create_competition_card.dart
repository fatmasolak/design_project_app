import 'package:design_project_app/models/competition_model.dart';
import 'package:flutter/material.dart';

class CreateCompetitionCard extends StatefulWidget {
  const CreateCompetitionCard({
    super.key,
    required this.competitions,
    required this.index,
    required this.status,
  });

  final List<CompetitionModel> competitions;
  final int index;
  final String status;

  @override
  State<StatefulWidget> createState() {
    return _CreateCompetitionCardState();
  }
}

class _CreateCompetitionCardState extends State<CreateCompetitionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        children: [
          Image(
            image: NetworkImage(
              widget.competitions[widget.index].competitionBanner,
            ),
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color.fromARGB(190, 0, 0, 0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.competitions[widget.index].competitionName,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.competitions[widget.index]
                                .competitionStartDate,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 25),
                          const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 25),
                          Text(
                            widget
                                .competitions[widget.index].competitionEndDate,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                            widget.status,
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
              ))
        ],
      ),
    );
  }
}
