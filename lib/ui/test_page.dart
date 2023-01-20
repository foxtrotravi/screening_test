import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/utils/utils.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test page'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              } catch (e) {
                showToast('Error: ${e.toString()}');
                debugPrint(e.toString());
              }
            },
            icon: const Icon(FeatherIcons.logOut),
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Text('Log in successful'),
      ),
    );
  }
}
