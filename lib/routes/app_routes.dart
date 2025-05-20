// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../utils/constants.dart'; // For route name constants

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRouteNames.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case AppRouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/verify-email':
        return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      // Add more routes here as your app grows
      // case AppRouteNames.settings:
      //   return MaterialPageRoute(builder: (_) => SettingsScreen());

      default:
        // If the route is unknown, you can navigate to a default screen
        // or show an error screen.
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
