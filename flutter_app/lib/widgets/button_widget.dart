import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final Key? key;
  final String text;
  final bool hasBorder;
  final double fontSize;
  final VoidCallback onPressed;

  ButtonWidget({
    this.key,
    this.text = '',
    this.hasBorder = false,
    this.fontSize = 16.0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: hasBorder ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(10.0),
          border: hasBorder
              ? Border.all(
                  color: Colors.blue,
                  width: 1.0,
                )
              : Border.fromBorderSide(BorderSide.none),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            height: 60.0,
            child: Center(
              child: Text(text,
                  style: TextStyle(
                    color: hasBorder ? Colors.blue : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
