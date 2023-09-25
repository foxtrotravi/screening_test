import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.validator,
    this.iconData,
    this.isPhoneNumber = false,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData? iconData;
  final String? Function(String?)? validator;
  final bool isPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
        suffixIcon: Icon(iconData),
        isDense: true,
      ),
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: isPhoneNumber ? TextInputType.number : null,
    );
  }
}
