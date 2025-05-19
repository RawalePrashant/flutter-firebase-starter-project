// lib/widgets/custom_button.dart

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined; // To create an outlined button style
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isOutlined = false,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveBackgroundColor = backgroundColor ?? theme.primaryColor;
    final Color effectiveTextColor = textColor ?? (isOutlined ? effectiveBackgroundColor : Colors.white);
    final BorderSide? borderSide = isOutlined ? BorderSide(color: effectiveBackgroundColor, width: 1.5) : null;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : effectiveBackgroundColor,
        foregroundColor: effectiveTextColor, // For ripple, icon, and text color
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderSide ?? BorderSide.none,
        ),
        elevation: isOutlined ? 0 : 2, // No elevation for outlined buttons
        shadowColor: isOutlined ? Colors.transparent : effectiveBackgroundColor.withOpacity(0.5),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // So the button doesn't stretch unnecessarily
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.0, color: effectiveTextColor), // Ensure icon color matches text
            const SizedBox(width: 8.0),
          ],
          Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: effectiveTextColor),
          ),
        ],
      ),
    );
  }
}
