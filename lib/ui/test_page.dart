import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/models/score.dart';
import 'package:screening_test/models/test_submission.dart';
import 'package:screening_test/ui/upload_resume.dart';
import 'package:screening_test/utils/utils.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  var _startTimer = false;
  var _isLoading = false;
  String loadingMessage = 'Loading questions';
  var _time = 15 * 60; // 15 minutes

  var questions = <Question>[];
  var selectedOptions = <String>[];

  final controller = PageController();
  int count = 3;
  bool isShowingDialog = false;

  @override
  void initState() {
    fetchQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fullScreenListener();

    return Scaffold(
      appBar: AppBar(
        title: Text(_startTimer ? showTimer(_time) : ''),
        actions: [
          TextButton(
            onPressed: submitTestConfirmation,
            child: const Text(
              'Finish & Submit Test',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: !_isLoading
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: PageView.builder(
                  controller: controller,
                  itemCount: questions.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final answer = questions[index].answer;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${index + 1}. ${question.text}'),
                        const SizedBox(height: 8),
                        RadioListTile<String>(
                          title: _buildOption(answer.isUrlA, answer.optionA),
                          groupValue: selectedOptions[index],
                          value: 'a',
                          onChanged: (String? value) {
                            setState(() {
                              selectedOptions[index] = value ?? 'a';
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: _buildOption(answer.isUrlB, answer.optionB),
                          groupValue: selectedOptions[index],
                          value: 'b',
                          onChanged: (String? value) {
                            setState(() {
                              selectedOptions[index] = value ?? 'b';
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: _buildOption(answer.isUrlC, answer.optionC),
                          groupValue: selectedOptions[index],
                          value: 'c',
                          onChanged: (String? value) {
                            setState(() {
                              selectedOptions[index] = value ?? 'c';
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: _buildOption(answer.isUrlD, answer.optionD),
                          groupValue: selectedOptions[index],
                          value: 'd',
                          onChanged: (String? value) {
                            setState(() {
                              selectedOptions[index] = value ?? 'd';
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Visibility(
                              visible: index != 0,
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.previousPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                  );
                                },
                                child: Text('Prev'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (index != questions.length - 1) {
                                  controller.nextPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                  );
                                } else {
                                  submitTestConfirmation();
                                }
                              },
                              child: Text(
                                index == questions.length - 1
                                    ? 'Submit'
                                    : 'Next',
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(loadingMessage),
                ],
              ),
            ),
    );
  }

  void fullScreenListener() {
    if (document.fullscreenElement != null) {
      return;
    }

    if (!isShowingDialog) {
      Timer(Duration.zero, () {
        showWarningDialog();
        if (count == 0) {
          showToast('Alert: Submitting test');
          submitTest(
            msg:
                'Submitting test as you exited fullscreen mode more than 3 times',
          );
        } else {
          showToast('Alert: $count times left');
          count--;
          goFullScreen();
        }
        isShowingDialog = true;
      });
    }
  }

  Future<void> fetchQuestions() async {
    setState(() {
      _isLoading = true;
      loadingMessage = 'Loading questions';
    });
    final querySnapshot =
        await FirebaseFirestore.instance.collection('questions').get();
    final allQuestions = <Question>[];
    querySnapshot.docs.forEach((doc) {
      allQuestions.add(Question.fromJson(doc.data()));
    });

    final lvlOne = <Question>[];
    final lvlTwo = <Question>[];
    final lvlThree = <Question>[];
    final lvlFour = <Question>[];

    allQuestions.forEach((q) {
      switch (q.level) {
        case 1:
          lvlOne.add(q);
          break;
        case 2:
          lvlTwo.add(q);
          break;
        case 3:
          lvlThree.add(q);
          break;
        case 4:
          lvlFour.add(q);
          break;
      }
    });

    // 2 questions from each level
    addTwoQuestions(lvlOne);
    addTwoQuestions(lvlTwo);
    addTwoQuestions(lvlThree);
    addTwoQuestions(lvlFour);

    selectedOptions = List<String>.filled(questions.length, '');
    startTimer();
  }

  void addTwoQuestions(List<Question> list) {
    final random = Random();
    final indexes = <int>{};

    while (true) {
      indexes.add(random.nextInt(list.length));
      if (indexes.length >= 2 || indexes.length >= list.length) {
        break;
      }
    }

    indexes.forEach((index) => questions.add(list[index]));
  }

  Future<void> startTimer() async {
    setState(() {
      _startTimer = true;
      _isLoading = false;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_time > 0) {
        if (mounted) {
          setState(() => _time--);
        }
      } else {
        timer.cancel();
        submitTest();
        debugPrint('stopped timer');
      }
    });
  }

  Future<void> submitTestConfirmation() async {
    showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm?'),
          content:
              const Text('Are you sure you want to submit & finish the test?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'No'),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'Yes'),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) async {
      if (value == 'Yes') {
        submitTest();
      }
    });
  }

  Future<void> submitTest({String msg = 'Submitting test'}) async {
    setState(() {
      _isLoading = true;
      loadingMessage = msg;
    });

    await uploadToFirebase();
    showToast('Test submitted successfully');
    navigateToUploadResume();
  }

  Future<void> uploadToFirebase() async {
    final questionIds = <String>[];
    final scoreArray = List.filled(4, 0);

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final isCorrect =
          selectedOptions[i].toLowerCase() == q.correctOption.toLowerCase();
      questionIds.add(q.uid!);
      scoreArray[q.level - 1] += (isCorrect ? 1 : 0);
    }

    final score = Score(
      level1: scoreArray[0],
      level2: scoreArray[1],
      level3: scoreArray[2],
      level4: scoreArray[3],
    );

    try {
      final doc = FirebaseFirestore.instance.collection('testSubmission').doc();

      final testSubmission = TestSubmission(
        uid: doc.id,
        userId: FirebaseAuth.instance.currentUser!.uid,
        score: score,
        questionIds: questions.map((e) => e.uid!).toList(),
        answers: selectedOptions,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await doc.set(testSubmission.toJson());
    } catch (e) {
      debugPrint(e.toString());
      showToast('Something went wrong');
    }
  }

  void navigateToUploadResume() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const UploadResumePage()),
      (_) => false,
    );
  }

  void showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isShowingDialog = false;
              });
            },
            child: const Text('Ok'),
          )
        ],
        content: const Text(
          'Your test will be automatically submitted if you exit fullscreen.',
        ),
      ),
    );
  }

  Widget _buildOption(bool isImage, String value) {
    if (isImage) {
      return SizedBox(
        height: 250,
        child: CachedNetworkImage(
          imageUrl: value,
          placeholder: (context, url) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );
    }
    return Text(value);
  }
}
