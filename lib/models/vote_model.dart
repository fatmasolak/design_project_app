class VoteModel {
  const VoteModel({
    required this.competitionId,
    required this.userId,
    required this.contestantId,
    required this.competitionPhoto,
    required this.competitionName,
    required this.contestantUsername,
  });

  final String competitionId;
  final String userId;
  final String contestantId;
  final String competitionPhoto;
  final String competitionName;
  final String contestantUsername;
}
