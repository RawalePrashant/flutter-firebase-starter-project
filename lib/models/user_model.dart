// lib/models/user_model.dart

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias to avoid name clash

/// A custom user model to represent authenticated users.
/// This can be extended with more user-specific data if needed.
class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  /// Factory constructor to create a UserModel from a Firebase User object.
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
    );
  }

  /// Returns true if the user signed in with Google.
  /// This is a basic check; more robust checks might involve looking at providerData.
  bool get isSignedInWithGoogle {
    // Check if the providerData contains a Google provider.
    return firebase_auth.FirebaseAuth.instance.currentUser?.providerData
            .any((userInfo) => userInfo.providerId == 'google.com') ??
        false;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL)';
  }
}
