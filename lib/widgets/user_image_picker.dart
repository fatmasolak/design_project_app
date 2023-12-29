import 'dart:io';

import 'package:design_project_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(
      {super.key, required this.onPickImage, required this.isDark});

  final void Function(File pickedImage) onPickImage;
  final bool isDark;

  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    var pickedImage;

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Choose source of photo'),
            actions: [
              TextButton(
                onPressed: () async {
                  pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                    maxWidth: 150,
                  );

                  Navigator.pop(context);
                },
                child: const Text("Gallery"),
              ),
              TextButton(
                onPressed: () async {
                  pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 50,
                    maxWidth: 150,
                  );

                  Navigator.pop(context);
                },
                child: const Text("Camera"),
              ),
            ],
          );
        });

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isDark)
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(
              Icons.image,
              color: primaryColor,
              size: 27,
            ),
            label: Text(
              _pickedImageFile == null ? 'Add Image' : 'Added',
              style: const TextStyle(
                color: primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (!widget.isDark)
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(
              Icons.image,
              color: Colors.white,
              size: 25,
            ),
            label: Text(
              _pickedImageFile == null ? 'Add Image' : 'Added',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
      ],
    );
  }
}
