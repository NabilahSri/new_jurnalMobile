import 'package:flutter/material.dart';

class TextformfieldCustom extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool? isObsecureText;
  final String? labelText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? readOnly;
  final double? height;
  final int? maxLines;
  const TextformfieldCustom({
    super.key,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isObsecureText = false,
    this.labelText,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.height = 45,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 7,
            )
          ]),
      child: TextFormField(
        maxLines: maxLines,
        readOnly: readOnly!,
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isObsecureText!,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          hintText: labelText,
          hintStyle: TextStyle(
            color: Colors.grey[350],
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
