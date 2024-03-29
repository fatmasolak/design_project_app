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
            backgroundColor: secondaryColor,
            title: const Text(
              'Choose source of photo',
              style: TextStyle(
                color: primaryColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );

                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
                child: const Text(
                  "Gallery",
                  style: TextStyle(
                    color: primaryColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );

                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
                child: const Text(
                  "Camera",
                  style: TextStyle(
                    color: primaryColor,
                  ),
                ),
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
