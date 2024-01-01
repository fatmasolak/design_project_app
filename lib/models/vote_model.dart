class VoteModel {
  const VoteModel({
    required this.competitionId,
    required this.userId,
    required this.contestantId,
    required this.competitionPhoto,
  });

  final String competitionId;
  final String userId;
  final String contestantId;
  final String competitionPhoto;
}
