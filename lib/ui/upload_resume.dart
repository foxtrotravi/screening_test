import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screening_test/ui/home_page.dart';
import 'package:screening_test/utils/utils.dart';

class UploadResumePage extends StatefulWidget {
  const UploadResumePage({super.key});

  @override
  State<UploadResumePage> createState() => _UploadResumePageState();
}

class _UploadResumePageState extends State<UploadResumePage> {
  UploadState uploadState = UploadState.none;
  UploadTask? uploadTask;
  Reference? ref;
  double progress = 0.0;
  String fileName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload resume')),
      body: Center(
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Upload resume'),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: uploadTask == null,
                  child: OutlinedButton(
                    onPressed: () {
                      pickFile();
                    },
                    child: const Center(
                      child: Text('Choose resume'),
                    ),
                  ),
                ),
                Visibility(
                  visible: uploadState == UploadState.paused ||
                      uploadState == UploadState.running,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${(progress * 100).toInt() / 100.0}%'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (progress / 100.0),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Visibility(
                            visible: uploadState == UploadState.running,
                            child: OutlinedButton(
                              onPressed: () async {
                                final paused = await uploadTask?.pause();
                                debugPrint('paused: $paused');
                              },
                              child: const Text('Pause'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Visibility(
                            visible: uploadState == UploadState.paused,
                            child: OutlinedButton(
                              onPressed: () async {
                                final resumed = await uploadTask?.resume();
                                debugPrint('resumed: $resumed');
                              },
                              child: const Text('Resume'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Visibility(
                            visible: uploadState == UploadState.paused ||
                                uploadState == UploadState.running,
                            child: OutlinedButton(
                              onPressed: () async {
                                await uploadTask?.cancel();
                                debugPrint('Upload Canceled');
                                uploadTask = null;
                                uploadState = UploadState.none;
                                fileName = '';
                                progress = 0.0;
                                setState(() {});
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Visibility(
                      visible: uploadState == UploadState.success ||
                          uploadState == UploadState.error,
                      child: OutlinedButton(
                        onPressed: () async {
                          debugPrint('Replace resume');
                          await ref?.delete();
                          uploadTask = null;
                          uploadState = UploadState.none;
                          fileName = '';
                          progress = 0.0;
                          setState(() {});
                          await pickFile();
                        },
                        child: const Text('Replace'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Visibility(
                      visible: uploadState == UploadState.success,
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          navigateToHomePage();
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );

    if (result != null) {
      debugPrint('User picked file');
      final size = result.files.first.size;
      debugPrint('File size: $size');
      if (size >= 5242880) {
        showToast('File size should be less than 5 MB');
        return;
      }

      Uint8List fileBytes = result.files.first.bytes!;
      fileName = result.files.first.name;
      debugPrint('Picked file: $fileName');

      try {
        final timestamp = getTimeStamp();
        ref = FirebaseStorage.instance.ref(
          'uploads/$timestamp-$fileName',
        );
        // Uploading resume
        uploadTask = ref!.putData(fileBytes);

        uploadTask!.snapshotEvents.listen(
          (TaskSnapshot taskSnapshot) async {
            progress = 100.0 *
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            debugPrint("Upload is $progress% complete.");
            switch (taskSnapshot.state) {
              case TaskState.paused:
                debugPrint('Paused');
                uploadState = UploadState.paused;
                break;
              case TaskState.running:
                uploadState = UploadState.running;
                break;
              case TaskState.success:
                debugPrint('Success');
                uploadState = UploadState.success;

                showToast('Upload complete');

                // Fetching download url
                final downloadUrl = await ref!.getDownloadURL();
                debugPrint('Download url: $downloadUrl');

                try {
                  final db = FirebaseFirestore.instance;
                  final user = FirebaseAuth.instance.currentUser;
                  await db.collection('users').doc(user!.uid).update({
                    'resume': downloadUrl,
                  });
                } catch (e) {
                  debugPrint('Something went wrong while saving resume link');
                  debugPrint(e.toString());
                }
                break;
              case TaskState.canceled:
                debugPrint('Canceled');
                uploadState = UploadState.canceled;
                break;
              case TaskState.error:
                debugPrint('Error');
                uploadState = UploadState.error;
                break;
            }
            setState(() {});
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
    } else {
      showToast('User cancelled picking file');
    }
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}

enum UploadState { none, paused, running, success, canceled, error }
