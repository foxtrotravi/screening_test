import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/ui/admin/edit_question.dart';
import 'package:screening_test/ui/home_page.dart';
import 'package:screening_test/utils/utils.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String loadingMessage = '';
  bool _isLoading = false;

  final _questions = <Question>[];

  @override
  void initState() {
    loadQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            onPressed: () async {
              logout();
            },
            icon: const Icon(FeatherIcons.logOut),
          )
        ],
      ),
      body: Row(
        children: [
          _drawer(),
          Expanded(
            child: !_isLoading
                ? Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Questions',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                openQuestion(isEdit: true);
                              },
                              child: const Text('Add new'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Card(
                            child: ListView.builder(
                              itemCount: _questions.length,
                              itemBuilder: (context, index) {
                                final q = _questions[index];
                                return InkWell(
                                  onTap: () {
                                    openQuestion(index: index);
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          child: Text(
                                            '${index + 1}. ${q.text}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text('Level ${q.level}'),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        onPressed: () {
                                          debugPrint('Edit');
                                          openQuestion(
                                            index: index,
                                            isEdit: true,
                                          );
                                        },
                                        icon: const Icon(FeatherIcons.edit),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          debugPrint('Delete');
                                        },
                                        icon: const Icon(FeatherIcons.trash),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : loader(),
          ),
        ],
      ),
    );
  }

  Center loader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 4),
          Text(loadingMessage),
        ],
      ),
    );
  }

  Future<void> logout() async {
    showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm?'),
          content: const Text('Are you sure you want to sign out?'),
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
          loadingMessage = 'Signing out';
        });

        try {
          await FirebaseAuth.instance.signOut();
          navigateToHomePage();
        } catch (e) {
          showToast('Error: ${e.toString()}');
          debugPrint(e.toString());
        }
      }
    });
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Drawer _drawer() {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Questions'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void openQuestion({int? index, bool isEdit = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          content: EditQuestionPage(
              isEdit: isEdit,
              question: index == null ? null : _questions[index],
              onSubmitCallback: (Question question) {
                if (index == null) {
                  // create
                  _questions.add(question);
                } else {
                  // update
                  _questions[index] = question;
                }
                setState(() {});
              }),
        );
      },
    );
  }

  Future<void> loadQuestions() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('questions').get();

    querySnapshot.docs.forEach((element) {
      debugPrint(element.data().toString());
      _questions.add(Question.fromJson(element.data()));
    });

    if (mounted) {
      setState(() {});
    }
  }
}
