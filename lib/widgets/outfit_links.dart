import 'package:design_project_app/constants.dart';
import 'package:design_project_app/models/links_model.dart';
import 'package:design_project_app/widgets/create_app_bar.dart';
import 'package:flutter/material.dart';

class OutfitLinks extends StatefulWidget {
  const OutfitLinks({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OutfitLinksState();
  }
}

class _OutfitLinksState extends State<OutfitLinks> {
  final _formKey = GlobalKey<FormState>();

  String dressLink = '';
  String jacketLink = '';
  String topClothingLink = '';
  String bottomWearLink = '';
  String shoesLink = '';
  String bagLink = '';

  LinksModel links = const LinksModel(
    dressLink: '',
    jacketLink: '',
    topClothingLink: '',
    bottomWearLink: '',
    shoesLink: '',
    bagLink: '',
    competitionName: '',
    competitionPhotoUrl: '',
    competitionId: '',
  );

  void _add() async {
    _formKey.currentState!.save();

    setState(() {
      links = LinksModel(
        dressLink: dressLink,
        jacketLink: jacketLink,
        topClothingLink: topClothingLink,
        bottomWearLink: bottomWearLink,
        shoesLink: shoesLink,
        bagLink: bagLink,
        competitionName: '',
        competitionPhotoUrl: '',
        competitionId: '',
      );
    });

    Navigator.pop(context, links);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Links added.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CreateAppBar(header: 'Links', isShowing: false),
      body: Container(
        height: size.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 30,
                      ),
                      child: Text(
                        'You can leave the link fields of items that are not in your outfit blank',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    dressField(size),
                    const SizedBox(height: 10),
                    jacketField(size),
                    const SizedBox(height: 10),
                    topClothingField(size),
                    const SizedBox(height: 10),
                    bottomWearField(size),
                    const SizedBox(height: 10),
                    shoesField(size),
                    const SizedBox(height: 10),
                    bagField(size),
                    const SizedBox(height: 30),
                    addLinksButton(size),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container dressField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Dress Link',
          focusColor: Colors.white70,
        ),
        onSaved: (value) {
          dressLink = value!;
        },
      ),
    );
  }

  Container jacketField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Jacket Link',
          focusColor: Colors.white70,
        ),
        onSaved: (value) {
          jacketLink = value!;
        },
      ),
    );
  }

  Container topClothingField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Top Clothing Link',
          focusColor: Colors.white70,
        ),
        onSaved: (value) {
          topClothingLink = value!;
        },
      ),
    );
  }

  Container bottomWearField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Bottom Wear Link',
          focusColor: Colors.white70,
        ),
        onSaved: (value) {
          bottomWearLink = value!;
        },
      ),
    );
  }

  Container shoesField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Shoes Link',
          focusColor: Colors.white70,
        ),
        onSaved: (value) {
          shoesLink = value!;
        },
      ),
    );
  }

  Container bagField(Size size) {
    return Container(
      width: size.width * 0.99,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      child: TextFormField(
        decoration: const InputDecoration(
          hintText: 'Bag Link',
          focusColor: Colors.white70,
        ),
        onSaved: (value) {
          bagLink = value!;
        },
      ),
    );
  }

  Container addLinksButton(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.06,
        child: ElevatedButton(
          onPressed: _add,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
          ),
          child: const Text('Add Links'),
        ),
      ),
    );
  }
}
