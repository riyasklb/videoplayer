import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  CustomFormField({
    super.key,
    required this.hintText,
    required this.regExpressionvalidation,
    required this.onSaved,
   // this.obscureText;
  });
  final String hintText;
  final RegExp regExpressionvalidation;
  final void Function(String?) onSaved;
  // final void Function(String?)obscureText;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //obscureText: obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: onSaved,
      validator: (value) {
        if (value != null && regExpressionvalidation.hasMatch(value)) {
          return null;
        }
        return 'Enter a vaid ${hintText}';
      },
      decoration: InputDecoration(hintText: hintText),
    );
  }
}
