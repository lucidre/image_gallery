import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_gallery/model/image.dart' as image_model;
import 'package:image_gallery/util/constants.dart';
import 'package:image_gallery/util/firebase_util.dart';
import 'package:image_picker/image_picker.dart';

class HomeFloatingActionBar extends StatelessWidget {
  //to add uploaded item to the image list
  final Function(image_model.Image) onUploadDone;

  const HomeFloatingActionBar({Key? key, required this.onUploadDone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      // isExtended: true,
      child: const Icon(Icons.upload),
      backgroundColor: Constants.kSecondaryColor,
      onPressed: () => showUploadDialog(context),
    );
  }

  //INITIAL DIALOG TO PICK FILE
  void showUploadDialog(BuildContext context) {
    var themeData = Theme.of(context).textTheme;
    var textTheme = themeData.bodyText1;
    var textStyle2 = themeData.bodyText2;

    Dialog dialog = Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 5,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              alignment: Alignment.center,
              width: 280,
              decoration: BoxDecoration(
                  color: Constants.kDialogColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: const Icon(
                Icons.drive_folder_upload,
                color: Colors.white,
                size: 100,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Please select file',
              style: textTheme,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  elevation: 5,
                ),
                onPressed: () {
                  var navigatorState = Navigator.of(context);
                  navigatorState.pop();
                  showFilePicker(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Text(
                    'Take a picture',
                    style: textStyle2!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  elevation: 5,
                ),
                onPressed: () {
                  var navigatorState = Navigator.of(context);
                  navigatorState.pop();
                  showFilePicker(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Text(
                    'Select file',
                    style: textStyle2.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 2),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4),
                    ),
                    side: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                onPressed: () {
                  var navigatorState = Navigator.of(context);
                  navigatorState.pop();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Text(
                    'Cancel',
                    style: textStyle2.copyWith(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    showGeneralDialog(
      context: context,
      barrierLabel: "Pick Document",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => dialog,
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(anim),
        child: child,
      ),
    );
  }

  void showFilePicker(BuildContext context, bool isCamera) async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    // Capture a photo

    if (image != null) {
      String filePath = image.path;
      if (filePath.isNotEmpty) {
        if (isCamera) {
          saveToDeviceStorage(filePath, context);
        }
        showUploadProgressDialog(File(filePath), context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File Selection Canceled')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File Selection Canceled')));
    }
  }

  saveToDeviceStorage(String filePath, BuildContext context) async {
    try {
      final bool isSaved = await GallerySaver.saveImage(filePath) ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved
              ? 'File Saved to device storage'
              : 'Error Occurred In Saving File'),
        ),
      );
    } catch (e) {
      showErrorSnackBar(context, e);
    }
  }

  void showUploadProgressDialog(File file, BuildContext context) async {
    var themeData = Theme.of(context).textTheme;
    var textTheme = themeData.bodyText1;

    Dialog dialog = Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 5,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              alignment: Alignment.center,
              width: 280,
              decoration: BoxDecoration(
                  color: Constants.kDialogColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: const Icon(
                Icons.drive_folder_upload,
                color: Colors.white,
                size: 100,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Uploading, please wait',
              style: textTheme,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
    showGeneralDialog(
      context: context,
      barrierLabel: "Uploading Document",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => dialog,
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(anim),
        child: child,
      ),
    );

    uploadDocument(file, context);
  }

  void uploadDocument(File file, BuildContext context) async {
    String fileName = file.path.split('/').last;
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');

    try {
      UploadTask uploadTask = firebaseStorageRef.putFile(file);
      final TaskSnapshot taskSnapshot = await uploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      var dateTime = DateTime.now().millisecondsSinceEpoch;
      await sFirebaseCloud.collection('images').add({
        'image_url': url,
        'date': dateTime.toString(),
      });
      showSnackBar('Upload Successful', context);
      onUploadDone(
          image_model.Image(image_url: url, date: dateTime.toString()));
    } catch (e) {
      showErrorSnackBar(context, e);
    }
    Navigator.of(context).pop();
  }

  void showErrorSnackBar(BuildContext context, Object exception) {
    final snackBar = SnackBar(content: Text(exception.toString()));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
