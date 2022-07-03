import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final Key? key;
  final String labelText;
  final IconData prefixIconData;
  final bool obscureText;
  final void Function(String) textChanged;

  TextFieldWidget({
    this.key,
    required this.labelText,
    required this.prefixIconData,
    required this.obscureText,
    required this.textChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: this.key,
      onChanged: textChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIconData, size: 18, color: Colors.blue),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue),
        ),
        filled: true,
      ),
    );
  }
}
