// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../widgets/profile_picture.dart';
import '../widgets/custom_button.dart'; // For a styled sign out button

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider to get the current user.
    // `watch` ensures the widget rebuilds if user data changes (e.g., display name update).
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('No user data available. Please log in.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ProfilePicture(
                    photoURL: user.photoURL,
                    displayName: user.displayName,
                    radius: 60, // Larger profile picture on profile screen
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.displayName ?? 'N/A',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? 'No email provided',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildProfileInfoTile(
                    context,
                    icon: Icons.perm_identity,
                    title: 'User ID (UID)',
                    subtitle: user.uid,
                  ),
                  if (user.email != null)
                    _buildProfileInfoTile(
                      context,
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: user.email!,
                    ),
                  // You can add more user details here if available
                  // e.g., phone number, account creation date etc.
                  // For example, to show if signed in with Google:
                  if (user.isSignedInWithGoogle)
                    _buildProfileInfoTile(
                      context,
                      icon: Icons.g_mobiledata,
                      title: 'Authentication',
                      subtitle: 'Signed in with Google',
                      iconColor: Colors.green,
                    ),

                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Sign Out',
                    onPressed: () async {
                      await authProvider.signOut();
                      // Navigate to login screen after sign out.
                      // AuthWrapper should handle this, but explicit navigation can be a fallback.
                      if (mounted && Navigator.canPop(context)) { // Check if widget is still in tree
                         Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                    icon: Icons.logout,
                  ),
                ],
              ),
            ),
    );
  }

  // Helper widget to build consistent info tiles
  Widget _buildProfileInfoTile(BuildContext context, {required IconData icon, required String title, required String subtitle, Color? iconColor}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[700])),
      ),
    );
  }

  // Helper for mounted check, useful in async gaps
  bool get mounted => true; // In StatelessWidget, this is always true if it's built.
                           // For StatefulWidget, use `mounted` property of State.
                           // This is a placeholder; real check needed in State objects.
}
