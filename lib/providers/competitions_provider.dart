import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_app/models/competition_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final dataProvider = StreamProvider<List<CompetitionModel>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.collection('competitions').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final competitionId = data['competitionId'] as String;
      final competitionName = data['competitionName'] as String;
      final competitionBanner = data['competitionBanner'] as String;
      final competitionStartDate = data['competitionStartDate'] as String;
      final competitionEndDate = data['competitionEndDate'] as String;

      return CompetitionModel(
        competitionId: competitionId,
        competitionName: competitionName,
        competitionBanner: competitionBanner,
        competitionStartDate: competitionStartDate,
        competitionEndDate: competitionEndDate,
      );
    }).toList();
  });
});
