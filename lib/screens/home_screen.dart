// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart'; // For route names
import '../widgets/profile_picture.dart'; // For displaying profile picture

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // It's generally safer to get the user from the provider's stream or a snapshot
    // but for a simple display, this can work if AuthWrapper ensures user is present.
    final UserModel? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouteNames.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authProvider.signOut();
              // AuthWrapper will handle navigation to LoginScreen
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (user != null) ...[
                ProfilePicture(
                  photoURL: user.photoURL,
                  displayName: user.displayName,
                  radius: 50, // Larger profile picture
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome, ${user.displayName ?? user.email ?? 'User'}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'UID: ${user.uid}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (user.email != null)
                  Text(
                    'Email: ${user.email}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 20),
                if (user.isSignedInWithGoogle)
                  Chip(
                    avatar: Icon(Icons.g_mobiledata_outlined, color: Colors.green[700]),
                    label: const Text('Signed in with Google'),
                    backgroundColor: Colors.green[100],
                  ),
              ] else ...[
                const Text('User data not available.'),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouteNames.profile);
                },
                child: const Text('Go to Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
