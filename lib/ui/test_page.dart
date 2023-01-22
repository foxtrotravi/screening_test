import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screening_test/models/question.dart';
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
    questions = await Question.dummyData();
    selectedOptions = List<String>.filled(questions.length, '');
    startTimer();
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
        await Future.delayed(const Duration(seconds: 4));
        showToast('Test submitted successfully');
        navigateToUploadResume();
      }
    });
  }

  void navigateToUploadResume() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UploadResumePage()),
    );
  }
}
