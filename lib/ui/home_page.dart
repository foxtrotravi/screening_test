import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/ui/admin_page.dart';
import 'package:screening_test/ui/test_page.dart';
import 'package:screening_test/utils/theme.dart';
import 'package:screening_test/utils/utils.dart';
import 'package:screening_test/widgets/common_text_field.dart';
import 'package:screening_test/widgets/instructions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  final _phoneNumberController = TextEditingController();
  final _phoneNumberFocusNode = FocusNode();

  final _collegeController = TextEditingController();
  final _collegeFocusNode = FocusNode();

  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  var _highestDegree = 'Select your highest degree'.toLowerCase();
  final _highestDegreeOptions = <String>[
    'Select your highest degree',
    'Diploma',
    'Bachelors',
    'Masters',
    'PhD',
    'Post-doc'
  ];

  var _workingStatus = 'Select your working status'.toLowerCase();
  final _workingStatusOptions = <String>[
    'Select your working status',
    'Currently working',
    'Current not working',
    'Serving notice period',
  ];

  var _yearsOfExperience = 'Years of experience'.toLowerCase();
  final _yearsOfExperienceOptions = [
    'Years of experience',
    'Less than 1 year',
    '1+ year',
    '2+ years',
    '3+ years',
    '5+ years',
  ];

  bool isAdmin = false;
  bool isObscuring = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBody(),
          Visibility(
            visible: isLoading,
            child: Container(
              color: Colors.white10,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  StreamBuilder<User?> _buildBody() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const SizedBox();
          case ConnectionState.waiting:
            return _loginWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasData) {
              final user = snapshot.data;
              if (user != null) {
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: ((context, _snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Something went wrong'),
                      );
                    }

                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return const CircularProgressIndicator();
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final collectionUser = _snapshot.data?.data();
                        if (collectionUser != null) {
                          final isAdmin = collectionUser['isAdmin'];
                          if (isAdmin) {
                            return const AdminPage();
                          } else {
                            return const TestPage();
                          }
                        }
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
                );
              } else {
                return _loginWidget();
              }
            }
        }
        return _loginWidget();
      },
    );
  }

  Row _loginWidget() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            alignment: Alignment.topLeft,
            child: const Instructions(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: darkGrey,
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(40),
            child: Form(
              key: _formKey,
              child: Card(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 40,
                        ),
                        children: [
                          _buildLoginType(),
                          const SizedBox(height: 40),
                          ...form(),
                        ],
                      ),
                    ),
                    _buildSubmit(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container _buildSubmit() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
        onPressed: validateAndSubmit,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(isAdmin ? 'Login' : 'Start test'),
        ),
      ),
    );
  }

  Row _buildLoginType() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isAdmin = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Candidate',
              style: isAdmin ? bold24LightGrey : bold24Dark,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            setState(() {
              isAdmin = true;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Admin',
              style: isAdmin ? bold24Dark : bold24LightGrey,
            ),
          ),
        ),
      ],
    );
  }

  void validateAndSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      submit();
    }
  }

  void submit() async {
    if (isAdmin) {
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Password: ${_passwordController.text}');
      _login();
    } else {
      goFullScreen();
      _handleCandidateLogin();

      debugPrint('Full name: ${_nameController.text}');
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Phone: ${_phoneNumberController.text}');
      debugPrint('College: ${_collegeController.text}');
      debugPrint('Highest degree: $_highestDegree');
      debugPrint('Working status: $_workingStatus');
      debugPrint('Years of experience: $_yearsOfExperience');
    }
  }

  String? _fullNameValidator(String? fullName) {
    if (fullName == null || fullName.isEmpty) return "Name can't be empty";
    if (fullName.length < 5) return "Full name too short";
    return null;
  }

  String? _emailValidator(String? email) {
    if (email == null || email.isEmpty) return "Email can't be empty";
    return (email.isValidEmail()) ? null : 'Invalid email';
  }

  String? _phoneNumberValidator(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return "Phone number can't be empty";
    }
    return (phoneNumber.length != 10) ? 'Invalid phone number' : null;
  }

  String? _collegeValidator(String? college) {
    if (college == null || college.isEmpty) return "College can't be empty";
    return null;
  }

  String? _yearsOfExperienceValidator(String? yrsOfExp) {
    if (yrsOfExp == 'Years of experience'.toLowerCase()) {
      return "Years of exp can't be empty";
    }
    return null;
  }

  String? _workingStatusValidator(String? workingStatus) {
    if (workingStatus == 'Select your working status'.toLowerCase()) {
      return "Working status can't be empty";
    }
    return null;
  }

  String? _highestDegreeValidator(String? highestDegree) {
    if (highestDegree == 'Select your highest degree'.toLowerCase()) {
      return "Highest degree can't be empty";
    }
    return null;
  }

  List<Widget> form() {
    final widgets = <Widget>[];
    if (isAdmin) {
      final adminForm = <Widget>[
        CommonTextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          hintText: 'Email',
          validator: _emailValidator,
          iconData: FeatherIcons.mail,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Password',
            suffix: SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                iconSize: 14,
                onPressed: () {
                  setState(() {
                    isObscuring = !isObscuring;
                  });
                },
                icon:
                    Icon(isObscuring ? FeatherIcons.eyeOff : FeatherIcons.eye),
              ),
            ),
            isDense: true,
          ),
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: isObscuring,
        )
      ];
      widgets.addAll(adminForm);
    } else {
      const dropdownDecoration = InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      );

      final candidateForm = [
        CommonTextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          hintText: 'Full name',
          validator: _fullNameValidator,
          iconData: FeatherIcons.user,
        ),
        const SizedBox(height: 20),
        CommonTextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          hintText: 'Email',
          validator: _emailValidator,
          iconData: FeatherIcons.mail,
        ),
        const SizedBox(height: 20),
        CommonTextField(
          controller: _phoneNumberController,
          focusNode: _phoneNumberFocusNode,
          hintText: 'Phone number',
          validator: _phoneNumberValidator,
          isPhoneNumber: true,
          iconData: FeatherIcons.phone,
        ),
        const SizedBox(height: 20),
        CommonTextField(
          controller: _collegeController,
          focusNode: _collegeFocusNode,
          hintText: 'College',
          validator: _collegeValidator,
          iconData: Icons.school_outlined,
        ),
        const SizedBox(height: 20),
        // Highest Degree
        DropdownButtonFormField(
          decoration: dropdownDecoration,
          value: _highestDegree,
          validator: _highestDegreeValidator,
          items: _highestDegreeOptions
              .map(
                (e) => DropdownMenuItem(
                  value: e.toLowerCase(),
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (String? selectedOption) {
            if (selectedOption != null) {
              _highestDegree = selectedOption;
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 20),
        // Working status
        DropdownButtonFormField(
          decoration: dropdownDecoration,
          value: _workingStatus,
          validator: _workingStatusValidator,
          items: _workingStatusOptions
              .map(
                (e) => DropdownMenuItem(
                  value: e.toLowerCase(),
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (String? selectedOption) {
            if (selectedOption != null) {
              _workingStatus = selectedOption;
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 20),
        // Years of experience
        DropdownButtonFormField(
          decoration: dropdownDecoration,
          validator: _yearsOfExperienceValidator,
          value: _yearsOfExperience,
          items: _yearsOfExperienceOptions
              .map(
                (e) => DropdownMenuItem(
                  value: e.toLowerCase(),
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (String? selectedOption) {
            if (selectedOption != null) {
              _yearsOfExperience = selectedOption;
            }
            setState(() {});
          },
        ),
        // Resume upload button
        const SizedBox(height: 40)
      ];
      widgets.addAll(candidateForm);
    }
    return widgets;
  }

  Future<void> _handleCandidateLogin() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _emailController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      _navigateToTest();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email. Logging your in');
        _login();
      }
    } catch (e) {
      showToast(e.toString());
    }
  }

  Future<void> _login() async {
    try {
      final password =
          isAdmin ? _passwordController.text : _emailController.text;

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: password.trim(),
      );

      final user = <String, dynamic>{};

      user['email'] = _emailController.text.trim();
      user['isAdmin'] = isAdmin;
      user['uid'] = credential.user!.uid;

      if (!isAdmin) {
        user['name'] = _nameController.text.trim();
        user['phoneNumber'] = _phoneNumberController.text.trim();
        user['college'] = _collegeController.text.trim();
        user['highestDegree'] = _highestDegree.trim();
        user['workingStatus'] = _workingStatus.trim();
        user['yearsOfExperience'] = _yearsOfExperience.trim();
      }

      final db = FirebaseFirestore.instance;

      final snapshot = await db.collection('users').doc(user['uid']).get();

      if (snapshot.data() == null) {
        final users = db.collection('users');
        final doc = users.doc(user['uid']);
        await doc.set(user);
      }

      setState(() {
        isLoading = false;
      });

      if (isAdmin) {
        _navigateToAdmin();
      } else {
        _navigateToTest();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showToast('Wrong password provided for that user.');
      }
    }
  }

  void _navigateToTest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TestPage()),
    );
  }

  void _navigateToAdmin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminPage()),
    );
  }
}
