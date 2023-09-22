import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/utils/utils.dart';

class AccessPage extends StatefulWidget {
  const AccessPage({super.key});

  @override
  State<AccessPage> createState() => _AccessPageState();
}

class _AccessPageState extends State<AccessPage> {
  final authorizedUsers =
      FirebaseFirestore.instance.collection('authorizedUsers');

  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Access Page',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText:
                                'NOTE: The email should be separated by new lines. Example: \n\nabc@gmail.com\nxyz@gmail.com',
                          ),
                          maxLines: 10,
                          controller: _textEditingController,
                          validator: (email) {
                            if (email == null || email.isEmpty) {
                              return "Email(s) can't be empty";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _grantAccess(true),
                              child: const Text('Grant Access'),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () => _grantAccess(false),
                              child: const Text('Revoke Access'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _grantAccess(bool access) async {
    final emails = _fetchEmail();

    for (final email in emails) {
      if (email.trim().isValidEmail()) {
        await authorizedUsers.doc(email.trim()).set(
          {
            'allowAccess': access,
            'email': email,
          },
          SetOptions(merge: true),
        );
      }
    }

    showToast(
      'Access ${access ? 'granted to' : 'revoked of'} ${emails.length} emails',
    );
  }

  List<String> _fetchEmail() {
    final text = _textEditingController.text;
    final list = text.split('\n');
    debugPrint(list.toString());
    return list;
  }
}
