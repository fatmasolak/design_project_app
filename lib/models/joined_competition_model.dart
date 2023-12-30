class JoinedCompetitionModel {
  const JoinedCompetitionModel({
    required this.username,
    required this.userId,
    required this.competitionName,
    required this.competitionId,
    required this.competitionPhoto,
    required this.numberOfVote,
  });

  final String username;
  final String userId;
  final String competitionName;
  final String competitionId;
  final String competitionPhoto;
  final int numberOfVote;
}
