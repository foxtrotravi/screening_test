import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/ui/admin/question_bank_page.dart';
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
                ? QuestionBank(_questions, (question, index) {
                    if (index == null) {
                      // create
                      _questions.add(question);
                    } else {
                      // update
                      _questions[index] = question;
                    }
                    setState(() {});
                  })
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
