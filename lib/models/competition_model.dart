class CompetitionModel {
  const CompetitionModel({
    required this.competitionId,
    required this.competitionName,
    required this.competitionBanner,
    required this.competitionStartDate,
    required this.competitionEndDate,
    required this.votingStartDate,
    required this.votingEndDate,
  });

  final String competitionId;
  final String competitionName;
  final String competitionBanner;
  final String competitionStartDate;
  final String competitionEndDate;
  final String votingStartDate;
  final String votingEndDate;
}
