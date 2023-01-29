import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/models/collection_user.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/models/test_submission.dart';
import 'package:screening_test/ui/admin/question_bank_page.dart';
import 'package:screening_test/ui/admin/reports_page.dart';
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
  int currentPage = 0;

  final _questions = <Question>[];
  final testSubmissions = <TestSubmission>[];

  final questionsMap = <String, Question>{};
  final testSubmissionMap = <String, TestSubmission>{};

  final users = <CollectionUser>[];
  final usersMap = <String, CollectionUser>{};

  @override
  void initState() {
    loadCollectionUsers();
    loadQuestions();
    loadTestSubmissions();
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
            child: !_isLoading ? _buildPage() : loader(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (currentPage) {
      case 0:
        return QuestionBank(_questions, (question, index) {
          if (index == null) {
            // create
            _questions.add(question);
          } else {
            // update
            _questions[index] = question;
          }
          setState(() {});
        });
      case 1:
        return ReportsPage(
          testSubmissions: testSubmissions,
          testSubmissionMap: testSubmissionMap,
          questionsMap: questionsMap,
          usersMap: usersMap,
        );
    }
    return const SizedBox();
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
          _buildListTile('Questions', 0),
          _buildListTile('Reports', 1),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, int index) {
    return ListTile(
      title: Text(title),
      selected: currentPage == index,
      selectedTileColor: Colors.grey[200],
      onTap: () => setState(() => currentPage = index),
    );
  }

  Future<void> loadQuestions() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('questions').get();
    final docs = querySnapshot.docs;

    for (final doc in docs) {
      debugPrint(doc.data().toString());
      final question = Question.fromJson(doc.data());
      _questions.add(question);
      questionsMap[question.uid!] = question;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadTestSubmissions() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('testSubmission').get();
    final docs = querySnapshot.docs;

    for (final doc in docs) {
      final testSubmission = TestSubmission.fromJson(doc.data());
      testSubmissions.add(testSubmission);
      testSubmissionMap[testSubmission.uid] = testSubmission;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadCollectionUsers() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    final docs = querySnapshot.docs;

    for (final doc in docs) {
      final collectionUser = CollectionUser.fromJson(doc.data());
      users.add(collectionUser);
      usersMap[collectionUser.uid] = collectionUser;
    }

    if (mounted) {
      setState(() {});
    }
  }
}
