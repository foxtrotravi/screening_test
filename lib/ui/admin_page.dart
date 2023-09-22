import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/models/collection_user.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/models/test_submission.dart';
import 'package:screening_test/ui/admin/access_page.dart';
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

  // Pagination Parameters
  bool isLoadingMoreReports = false; // track if fetching more reports
  bool isLoadingMoreUsers = false; // track if fetching more users
  bool hasMoreReports = true; // flag for more reports available or not
  bool hasMoreUsers = true; // flag for more users available or not
  int reportsDocumentLimit = 20; // documents to be fetched per request
  int usersDocumentLimit = 20; // documents to be fetched per request
  DocumentSnapshot? reportLastDocument;
  DocumentSnapshot? userLastDocument;

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
      drawer: _drawer(),
      body: Row(
        children: [
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
        return QuestionBank(
          questions: _questions,
          questionCallback: (question, index) {
            if (index == null) {
              // create
              _questions.add(question);
            } else {
              // update
              _questions[index] = question;
            }
            setState(() {});
          },
          loadMoreCallback: () {
            loadQuestions();
          },
        );
      case 1:
        return ReportsPage(
          testSubmissions: testSubmissions,
          testSubmissionMap: testSubmissionMap,
          questionsMap: questionsMap,
          users: users,
          usersMap: usersMap,
          callback: () {
            loadTestSubmissions();
          },
        );
      case 2:
        return const AccessPage();
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
          _buildListTile('Access', 2),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, int index) {
    return ListTile(
      title: Text(title),
      selected: currentPage == index,
      selectedTileColor: Colors.grey[200],
      onTap: () {
        setState(() => currentPage = index);
        Navigator.of(context).pop();
      },
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
      setState(() {
        isLoadingMoreUsers = false;
      });
    }
  }

  Future<void> loadTestSubmissions() async {
    debugPrint('Loading more\n\n\n\n');
    if (!hasMoreReports) {
      debugPrint('No More Submissions');
      return;
    }
    if (isLoadingMoreReports) {
      return;
    }
    setState(() {
      isLoadingMoreReports = true;
    });

    late QuerySnapshot querySnapshot;

    if (reportLastDocument == null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('testSubmission')
          .limit(reportsDocumentLimit)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('testSubmission')
          .startAfterDocument(reportLastDocument!)
          .limit(reportsDocumentLimit)
          .get();
    }
    final docs = querySnapshot.docs;

    for (final doc in docs) {
      if (doc.data() != null) {
        final testSubmission =
            TestSubmission.fromJson(doc.data()! as Map<String, dynamic>);
        testSubmissions.add(testSubmission);
        testSubmissionMap[testSubmission.uid] = testSubmission;
      }
    }

    if (docs.length < reportsDocumentLimit) {
      hasMoreReports = false;
    }
    reportLastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];

    if (mounted) {
      setState(() {
        isLoadingMoreReports = false;
      });
    }
  }

  Future<void> loadCollectionUsers() async {
    if (!hasMoreUsers) {
      debugPrint('No More Products');
      return;
    }
    if (isLoadingMoreUsers) {
      return;
    }
    setState(() {
      isLoadingMoreUsers = true;
    });

    late QuerySnapshot querySnapshot;

    if (userLastDocument == null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .limit(usersDocumentLimit)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .startAfterDocument(userLastDocument!)
          .limit(usersDocumentLimit)
          .get();
    }

    final docs = querySnapshot.docs;

    for (final doc in docs) {
      if (doc.data() != null) {
        final collectionUser =
            CollectionUser.fromJson(doc.data()! as Map<String, dynamic>);
        users.add(collectionUser);
        usersMap[collectionUser.uid] = collectionUser;
      }
    }

    if (docs.length < usersDocumentLimit) {
      hasMoreUsers = false;
    }
    userLastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];

    if (mounted) {
      setState(() {});
    }
  }
}
