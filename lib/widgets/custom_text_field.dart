// lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.focusNode,
    this.onChanged,
    this.inputFormatters,
    this.enabled = true,
    this.maxLength,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = !widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText && !_isPasswordVisible,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: theme.primaryColor.withOpacity(0.7)) : null,
        // Use theme's input decoration as a base
        border: theme.inputDecorationTheme.border ?? const OutlineInputBorder(),
        enabledBorder: theme.inputDecorationTheme.enabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8.0),
            ),
        focusedBorder: theme.inputDecorationTheme.focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
        errorBorder: theme.inputDecorationTheme.errorBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
              borderRadius: BorderRadius.circular(8.0),
            ),
        focusedErrorBorder: theme.inputDecorationTheme.focusedErrorBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
        filled: true,
        fillColor: Colors.grey.shade100.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      style: const TextStyle(fontSize: 16.0),
    );
  }
}
