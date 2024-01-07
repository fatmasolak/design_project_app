class ResultModel {
  const ResultModel({
    required this.competitionId,
    required this.competitionName,
    required this.contestantId,
    required this.numberOfVotes,
    required this.rank,
    required this.contestantPhoto,
    required this.contestantUsername,
  });

  final String competitionId;
  final String competitionName;
  final String contestantId;
  final int numberOfVotes;
  final int rank;
  final String contestantPhoto;
  final String contestantUsername;
}
