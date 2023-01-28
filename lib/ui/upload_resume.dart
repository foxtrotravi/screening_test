import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          pickFile();
                        },
                        child: const Center(
                          child: Text('Choose resume (doc, pdf, jpg)'),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          navigateToHomePage();
                        },
                        child: const Center(
                          child: Text('Skip resume & logout'),
                        ),
                      ),
                    ],
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
    await pickFileUtil(
      (file) async {
        debugPrint('User picked file');
        final size = file.size;
        debugPrint('File size: $size');
        if (size >= 5242880) {
          showToast('File size should be less than 5 MB');
          return;
        }
        fileName = file.name;
        debugPrint('Picked file: $fileName');

        final timestamp = getTimeStamp();
        await uploadToFirebase(
          file,
          'uploads/$timestamp-$fileName',
        );
      },
      fileType: ['pdf', 'doc', 'jpg', 'png'],
    );
  }

  Future<void> uploadToFirebase(PlatformFile file, String referencePath) async {
    await uploadToFirebaseUtil(
      file,
      referencePath,
      (state, reference, progressPercentage, {uploadTask}) async {
        this.uploadTask = uploadTask!;
        progress = progressPercentage;
        switch (state) {
          case TaskState.paused:
            uploadState = UploadState.paused;
            break;
          case TaskState.running:
            uploadState = UploadState.running;
            break;
          case TaskState.success:
            uploadState = UploadState.success;
            showToast('Upload complete');
            // Fetching download url
            final downloadUrl = await reference.getDownloadURL();
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
            uploadState = UploadState.canceled;
            break;
          case TaskState.error:
            uploadState = UploadState.error;
            break;
        }
        setState(() {});
      },
    );
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}

enum UploadState { none, paused, running, success, canceled, error }
