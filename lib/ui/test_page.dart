import 'dart:async';
import 'dart:math';

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

  @override
  void initState() {
    fetchQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_startTimer ? showTimer(_time) : ''),
        actions: [
          TextButton(
            onPressed: submitTest,
            child: const Text('Finish & Submit Test'),
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
                          title: Text(answer.optionA),
                          groupValue: selectedOptions[index],
                          value: 'a',
                          onChanged: (String? value) {
                            setState(() {
                              selectedOptions[index] = value ?? 'a';
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(answer.optionB),
                          groupValue: selectedOptions[index],
                          value: 'b',
                          onChanged: (String? value) {
                            setState(() {
                              selectedOptions[index] = value ?? 'b';
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(answer.optionC),
                          groupValue: selectedOptions[index],
                          value: 'c',
                          onChanged: (String? value) {
                            setState(() {
                              selectedOptions[index] = value ?? 'c';
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(answer.optionD),
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
                                  submitTest();
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
                  Text(loadingMessage),
                ],
              ),
            ),
    );
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

    // questions = await Question.dummyData();
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

    indexes.forEach((index) {
      questions.add(list[index]);
    });
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
        debugPrint('stopped timer');
      }
    });
  }

  Future<void> submitTest() async {
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
        setState(() {
          _isLoading = true;
          loadingMessage = 'Submitting test';
        });

        await uploadToFirebase();
        showToast('Test submitted successfully');
        navigateToUploadResume();
      }
    });
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UploadResumePage()),
    );
  }
}
