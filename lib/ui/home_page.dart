import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              alignment: Alignment.topLeft,
              child: const Instructions(),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Container(
              color: darkGrey,
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: Card(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(40),
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text('Login', style: bold24Dark),
                      ),
                      const SizedBox(height: 40),
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
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
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: validateAndSubmit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: const Text('Start test'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      submit();
    }
  }

  void submit() {
    // Todo: Implement submit
    debugPrint('Full name: ${_nameController.text}');
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Phone: ${_phoneNumberController.text}');
    debugPrint('College: ${_collegeController.text}');
    debugPrint('Highest degree: $_highestDegree');
    debugPrint('Working status: $_workingStatus');
    debugPrint('Years of experience: $_yearsOfExperience');
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
}
