// lib/utils/constants.dart

import 'package:flutter/material.dart';

/// AppRouteNames contains all the route names used in the application.
/// Using constants for route names helps prevent typos and makes refactoring easier.
class AppRouteNames {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  // Add other route names here
  // static const String settings = '/settings';
  // static const String productDetail = '/product-detail';
}

/// AppColors defines a palette of colors used throughout the application.
/// This promotes consistency in UI design.
class AppColors {
  static const Color primaryColor = Colors.blue; // Example primary color
  static const Color accentColor = Colors.lightBlueAccent; // Example accent color
  static const Color textColor = Colors.black87;
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Colors.redAccent;
  // Add more colors as needed
}

/// AppTextStyles provides predefined text styles.
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textColor);
  static const TextStyle bodyText1 = TextStyle(fontSize: 16, color: AppColors.textColor);
  // Add more text styles
}

/// Other constants can be defined here, for example, API keys (though sensitive keys
/// should ideally be stored securely, e.g., using environment variables via flutter_dotenv).
class AppConstants {
  static const String appName = 'My Flutter Firebase App';
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  // Example:
  // static const String googleApiKey = "YOUR_GOOGLE_API_KEY_HERE"; // Be cautious with API keys
}
