import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_app/constants.dart';
import 'package:design_project_app/models/joined_competition_model.dart';
import 'package:design_project_app/models/links_model.dart';
import 'package:design_project_app/models/result_model.dart';
import 'package:design_project_app/models/vote_model.dart';
import 'package:design_project_app/screens/user_screens/competition_photo_screen.dart';
import 'package:design_project_app/widgets/create_app_bar.dart';
import 'package:design_project_app/widgets/create_competition_photo_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  String name = '';
  String surname = '';
  String username = '';
  String profilePhoto = '';

  List<String> myJoinedCompetitionIds = [];
  List<String> competitionIds = [];
  List<JoinedCompetitionModel> myCompetitions = [];
  List<String> userIds = [];
  List<VoteModel> myFavorites = [];
  List<ResultModel> myResults = [];
  List<LinksModel> myLinks = [];

  bool isLoading = false;
  bool isCompetitionPhotosShow = false;
  bool isFavoritesShow = false;
  bool isResultsShow = false;
  bool isLinksShow = false;

  @override
  void initState() {
    super.initState();
    _getUserInformations();
    _loadCompetitionIds();
    _loadUserIds();
  }

  void _getUserInformations() async {
    String foundedName = '';
    String foundedSurname = '';
    String foundedUsername = '';
    String foundedProfilePhoto = '';

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if (data['userId'] == FirebaseAuth.instance.currentUser!.uid) {
            foundedName = data['name'];
            foundedSurname = data['surname'];
            foundedUsername = data['username'];
            foundedProfilePhoto = data['profilePhoto'];
          }
        }
      } else {
        print('No data found');
      }

      setState(() {
        name = foundedName;
        surname = foundedSurname;
        username = foundedUsername;
        profilePhoto = foundedProfilePhoto;
      });
    } catch (error) {
      print(error);
    }
  }

  void _loadCompetitionIds() async {
    List<String> loadedCompetitionIds = [];

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('competitions').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          loadedCompetitionIds.add(data['competitionId']);
        }
      } else {
        print('No data found');
      }

      setState(() {
        competitionIds = loadedCompetitionIds;
      });
    } catch (error) {
      setState(() {
        print('Something went wrong. Please try again later.');
      });
    }

    _loadMyCompetitions(competitionIds);
    _loadMyJoinedCompetitionsIds(competitionIds);
  }

  void _loadUserIds() async {
    List<String> loadedUserIds = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          loadedUserIds.add(data['userId']);
        }
      } else {
        print('No data found');
      }

      setState(() {
        userIds = loadedUserIds;
      });
    } catch (error) {
      setState(() {
        print('Something went wrong. Please try again later.');
      });
    }

    _loadFavorites(competitionIds, userIds);
  }

  void _loadMyJoinedCompetitionsIds(List competitionIds) async {
    List<String> loadedMyJoinedCompetitionsIds = [];

    try {
      for (var id in competitionIds) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('joinedCompetitions')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection(id)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            loadedMyJoinedCompetitionsIds.add(data['competitionId']);
          }
        } else {
          print('No data found');
        }
      }

      setState(() {
        myJoinedCompetitionIds = loadedMyJoinedCompetitionsIds;
      });
    } catch (error) {
      print(error);
    }

    _loadResults(myJoinedCompetitionIds);
  }

  void _loadMyCompetitions(List competitionIds) async {
    List<JoinedCompetitionModel> loadedJoinedCompetitions = [];

    try {
      print('competitions');

      for (var id in competitionIds) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('joinedCompetitions')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection(id)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            JoinedCompetitionModel competition = JoinedCompetitionModel(
              username: data['username'],
              userId: data['userId'],
              competitionName: data['competitionName'],
              competitionId: data['competitionId'],
              competitionPhoto: data['competitionPhoto'],
              numberOfVote: data['numberOfVote'],
              weight: data['weight'],
            );

            loadedJoinedCompetitions.add(competition);
          }
        } else {
          print('No data found');
        }
      }

      setState(() {
        myCompetitions = loadedJoinedCompetitions;
      });
    } catch (error) {
      print(error);
    }
  }

  void _loadFavorites(List competitionIds, List userIds) async {
    List<VoteModel> loadedFavorites = [];

    try {
      print('favorites');

      for (var competitionId in competitionIds) {
        for (var userId in userIds) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('votes')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('$competitionId$userId')
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            for (var doc in querySnapshot.docs) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              VoteModel favorite = VoteModel(
                competitionId: data['competitionId'],
                userId: data['userId'],
                contestantId: data['contestantId'],
                competitionPhoto: data['competitionPhoto'],
                competitionName: data['competitionName'],
                contestantUsername: data['contestantUsername'],
              );

              loadedFavorites.add(favorite);
            }
          } else {
            print('No data found');
          }
        }
      }

      setState(() {
        myFavorites = loadedFavorites;
        isLoading = false;
      });
    } catch (error) {
      print(error);
    }
  }

  void _loadResults(List myJoinedCompetitionIds) async {
    List<ResultModel> loadedResults = [];

    try {
      print('results');

      for (var id in myJoinedCompetitionIds) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('results')
            .doc(id)
            .collection(FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            ResultModel result = ResultModel(
              competitionId: data['competitionId'],
              competitionName: data['competitionName'],
              contestantId: data['contestantId'],
              numberOfVotes: data['numberOfVotes'],
              rank: data['rank'],
              contestantPhoto: data['contestantPhoto'],
              contestantUsername: data['contestantUsername'],
            );

            loadedResults.add(result);

            print(result.competitionName);
            print(result.rank);
            print(result.numberOfVotes);
          }
        } else {
          print('No data found');
        }
      }

      setState(() {
        myResults = loadedResults;
      });
    } catch (error) {
      print(error);
    }

    _loadLinks(myJoinedCompetitionIds);
  }

  void _loadLinks(List myJoinedCompetitionIds) async {
    List<LinksModel> loadedLinks = [];

    try {
      print('links');

      for (var competitionId in myJoinedCompetitionIds) {
        print(competitionId);

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('links')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection(competitionId)
            .get();

        print('hello');

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            LinksModel link = LinksModel(
              dressLink: data['dressLink'],
              jacketLink: data['jacketLink'],
              topClothingLink: data['topClothingLink'],
              bottomWearLink: data['bottomWearLink'],
              shoesLink: data['shoesLink'],
              bagLink: data['bagLink'],
              competitionName: data['competitionName'],
              competitionPhotoUrl: data['competitionPhoto'],
              competitionId: data['competitionId'],
            );

            loadedLinks.add(link);

            for (var link in loadedLinks) {
              print(link.dressLink);
              print(link.jacketLink);
              print(link.shoesLink);
            }
          }
        } else {
          print('No data found');
        }
      }

      setState(() {
        myLinks = loadedLinks;
      });
    } catch (error) {
      print('links: $error');
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: const CreateAppBar(header: 'Fashion', isShowing: true),
      body: !isLoading
          ? Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    userBanner(),
                    Expanded(
                      child: Column(
                        children: [
                          profilePageMenu(),
                          if (isCompetitionPhotosShow) showCompetitionPhotos(),
                          if (isFavoritesShow) showFavorites(),
                          if (isResultsShow) showResults(),
                          if (isLinksShow) showLinks(),
                        ],
                      ),
                    ),
                  ],
                ),
                userProfilePhoto(context),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
    );
  }

  Expanded showResults() {
    return (myResults.isNotEmpty)
        ? Expanded(
            child: ListView.builder(
              itemCount: myResults.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    color: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image(
                            image: NetworkImage(
                              myResults[index].contestantPhoto,
                            ),
                            height: 200,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              myResults[index].competitionName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Username: ${myResults[index].contestantUsername}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              'Number Of Votes: ${myResults[index].numberOfVotes}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              'Rank: ${myResults[index].rank}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : const Expanded(
            child: Center(
              child: Text(
                'No any results',
              ),
            ),
          );
  }

  Expanded showFavorites() {
    return (myFavorites.isNotEmpty)
        ? Expanded(
            child: ListView.builder(
              itemCount: myFavorites.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    child: Card(
                      color: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image(
                              image: NetworkImage(
                                myFavorites[index].competitionPhoto,
                              ),
                              height: 200,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(myFavorites[index].contestantUsername),
                              Text(myFavorites[index].competitionName),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : const Expanded(
            child: Center(
              child: Text(
                'No any favorites',
              ),
            ),
          );
  }

  Expanded showCompetitionPhotos() {
    return (myCompetitions.isNotEmpty)
        ? Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: myCompetitions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompetitionPhotoScreen(
                            competitionName:
                                myCompetitions[index].competitionName,
                            competitionPhoto:
                                myCompetitions[index].competitionPhoto,
                          ),
                        ),
                      );
                    },
                    child: CreateCompetitionPhotoCard(
                      competitionName: myCompetitions[index].competitionName,
                      competitionPhoto: myCompetitions[index].competitionPhoto,
                    ),
                  ),
                );
              },
            ),
          )
        : const Expanded(
            child: Center(
              child: Text(
                'No any joined competitions',
              ),
            ),
          );
  }

  Expanded showLinks() {
    return (myLinks.isNotEmpty)
        ? Expanded(
            child: ListView.builder(
              itemCount: myLinks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    child: Card(
                      color: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image(
                              image: NetworkImage(
                                myLinks[index].competitionPhotoUrl,
                              ),
                              height: 200,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                myLinks[index].competitionName,
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (myLinks[index].dressLink != '')
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    'Dress: ${myLinks[index].dressLink}',
                                    style: const TextStyle(color: primaryColor),
                                    maxLines: 2,
                                  ),
                                ),
                              if (myLinks[index].jacketLink != '')
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    'Jacket: ${myLinks[index].jacketLink}',
                                    style: const TextStyle(color: primaryColor),
                                    maxLines: 2,
                                  ),
                                ),
                              if (myLinks[index].topClothingLink != '')
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    'Top Clothing: ${myLinks[index].topClothingLink}',
                                    style: const TextStyle(color: primaryColor),
                                    maxLines: 2,
                                  ),
                                ),
                              if (myLinks[index].bottomWearLink != '')
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    'Bottom Wear: ${myLinks[index].bottomWearLink}',
                                    style: const TextStyle(color: primaryColor),
                                    maxLines: 2,
                                  ),
                                ),
                              if (myLinks[index].shoesLink != '')
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    'Shoes: ${myLinks[index].shoesLink}',
                                    style: const TextStyle(color: primaryColor),
                                    maxLines: 2,
                                  ),
                                ),
                              if (myLinks[index].bagLink != '')
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    'Bag: ${myLinks[index].bagLink}',
                                    style: const TextStyle(color: primaryColor),
                                    maxLines: 2,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : const Expanded(
            child: Center(
              child: Text(
                'No any links',
              ),
            ),
          );
  }

  Row profilePageMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        linksMenuBotton(),
        competitionPhotosMenuButton(),
        showUsername(),
        resultsMenuButton(),
        favoritesMenuButton(),
      ],
    );
  }

  Column favoritesMenuButton() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              isCompetitionPhotosShow = false;
              isResultsShow = false;
              isLinksShow = false;
              isFavoritesShow = true;
            });
          },
          style: TextButton.styleFrom(
            iconColor: primaryColor,
            foregroundColor: thirdColor,
          ),
          child: const Padding(
            padding: EdgeInsets.only(
              top: 0,
            ),
            child: Icon(
              Icons.favorite,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Column resultsMenuButton() {
    return Column(
      children: [
        const SizedBox(height: 70),
        TextButton(
          onPressed: () {
            setState(() {
              isCompetitionPhotosShow = false;
              isFavoritesShow = false;
              isLinksShow = false;
              isResultsShow = true;
            });
          },
          style: TextButton.styleFrom(
            iconColor: primaryColor,
            foregroundColor: thirdColor,
          ),
          child: const Padding(
            padding: EdgeInsets.only(
              top: 0,
              right: 0,
            ),
            child: Icon(
              Icons.event_note_outlined,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

  Column showUsername() {
    return Column(
      children: [
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Text(
            '#$username',
            style: const TextStyle(fontSize: 16, color: primaryColor),
          ),
        ),
      ],
    );
  }

  Column competitionPhotosMenuButton() {
    return Column(
      children: [
        const SizedBox(height: 70),
        TextButton(
          onPressed: () {
            setState(() {
              isFavoritesShow = false;
              isResultsShow = false;
              isLinksShow = false;
              isCompetitionPhotosShow = true;
            });
          },
          style: TextButton.styleFrom(
            iconColor: primaryColor,
            foregroundColor: thirdColor,
          ),
          child: const Padding(
            padding: EdgeInsets.only(
              top: 0,
              left: 0,
            ),
            child: Icon(
              Icons.image,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

  Column linksMenuBotton() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              isFavoritesShow = false;
              isResultsShow = false;
              isCompetitionPhotosShow = false;
              isLinksShow = true;
            });
          },
          style: TextButton.styleFrom(
            iconColor: primaryColor,
            foregroundColor: thirdColor,
          ),
          child: const Padding(
            padding: EdgeInsets.only(
              top: 0,
            ),
            child: Icon(
              Icons.insert_link,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Positioned userProfilePhoto(BuildContext context) {
    return Positioned(
      top: 220,
      left: MediaQuery.of(context).size.width / 2 - 75,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: secondaryColor),
          image: DecorationImage(
            image: NetworkImage(profilePhoto),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Container userBanner() {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://firebasestorage.googleapis.com/v0/b/design-project-app.appspot.com/o/user_banners%2Fbanner.JPG?alt=media&token=77aaa9dd-a9e5-4ad2-8395-56e97b76a030',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
