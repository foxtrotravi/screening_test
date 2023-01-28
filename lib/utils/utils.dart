import 'dart:html';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

void showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    timeInSecForIosWeb: 3,
  );
}

void goFullScreen() {
  try {
    document.documentElement?.requestFullscreen();
  } catch (e) {
    debugPrint('Something went wrong');
    debugPrint(e.toString());
  }
}

String showTimer(int time) {
  final hh = (time ~/ 3600);
  final mm = (time % 3600) ~/ 60;
  final ss = ((time % 3600) % 60).toInt();
  return '${twoDigit(hh)}:${twoDigit(mm)}:${twoDigit(ss)}';
}

String twoDigit(int t) {
  return t < 10 ? '0$t' : '$t';
}

String getTimeStamp() {
  final now = DateTime.now();
  final yyyy = now.year;
  final mm = twoDigit(now.month);
  final dd = twoDigit(now.day);

  return '$yyyy-$mm-$dd';
}

Future<void> uploadToFirebaseUtil(
  PlatformFile file,
  String referencePath,
  Function(TaskState state, Reference reference, double progress,
          {UploadTask? uploadTask})
      callback,
) async {
  try {
    final ref = FirebaseStorage.instance.ref(referencePath);
    final uploadTask = ref.putData(file.bytes!);
    var percent = 0.0;

    uploadTask.snapshotEvents.listen(
      (snapshot) {
        percent = 100.0 * (snapshot.bytesTransferred / snapshot.totalBytes);
        callback(snapshot.state, ref, percent, uploadTask: uploadTask);
      },
      onError: (error) {
        showToast('Something went wrong in listener');
        debugPrint(error.toString());
      },
    );
  } on FirebaseException catch (e) {
    debugPrint('FirebaseException');
    debugPrint(e.toString());
  } catch (e) {
    debugPrint('Something went wrong');
    debugPrint(e.toString());
  }
}

Future<void> pickFileUtil(
  void Function(PlatformFile file) callback, {
  List<String>? fileType,
}) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: fileType,
  );

  if (result != null) {
    callback(result.files.first);
  } else {
    showToast('User cancelled picking file');
  }
}
