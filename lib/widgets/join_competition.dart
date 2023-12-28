import 'dart:ui';
import 'package:flutter/material.dart';

class JoinCompetition extends StatefulWidget {
  const JoinCompetition({super.key, required this.competitionBanner});

  final String competitionBanner;

  @override
  State<JoinCompetition> createState() => _JoinCompetitionState();
}

class _JoinCompetitionState extends State<JoinCompetition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            widget.competitionBanner,
            fit: BoxFit.cover,
          ),
          Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black
                    .withOpacity(0.5), // Bulanıklığın rengi ve opaklığı
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: const Text('Join'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          const Column(
            children: [],
          ),
        ],
      ),
    );
  }
}
