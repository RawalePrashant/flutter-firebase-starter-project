// lib/widgets/profile_picture.dart

import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? photoURL;
  final String? displayName;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;

  const ProfilePicture({
    super.key,
    this.photoURL,
    this.displayName,
    required this.radius,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 20.0, // Default font size for initials
  });

  String get _initials {
    if (displayName == null || displayName!.trim().isEmpty) {
      return '?'; // Default if no name
    }
    final names = displayName!.trim().split(' ');
    if (names.length > 1 && names[0].isNotEmpty && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.primaryColor.withOpacity(0.3);
    final effectiveTextColor = textColor ?? theme.primaryColorDark;

    // Check if photoURL is valid and not empty
    final bool hasValidPhotoUrl = photoURL != null && photoURL!.trim().isNotEmpty && Uri.tryParse(photoURL!)?.hasAbsolutePath == true;

    return CircleAvatar(
      radius: radius,
      backgroundColor: hasValidPhotoUrl ? Colors.transparent : effectiveBackgroundColor, // Transparent if image, else color
      backgroundImage: hasValidPhotoUrl ? NetworkImage(photoURL!) : null,
      onBackgroundImageError: hasValidPhotoUrl ? (exception, stackTrace) {
        // Optionally handle image loading errors, e.g., log them
        // This widget will fall back to initials if image fails.
        // To force a rebuild to show initials on error, you'd need a StatefulWidget
        // and manage the error state. For simplicity, this version doesn't.
        debugPrint("Error loading profile image: $exception");
      } : null,
      child: (photoURL == null || photoURL!.trim().isEmpty)
          ? Center(
              child: Text(
                _initials,
                style: TextStyle(
                  fontSize: radius * 0.8, // Scale font size with radius
                  fontWeight: FontWeight.bold,
                  color: effectiveTextColor,
                ),
              ),
            )
          : null, // No child if backgroundImage is set
    );
  }
}
