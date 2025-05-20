// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kDebugMode; // For print statements in debug mode

/// AuthService class handles all Firebase Authentication related operations.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optionally configure scopes if you need more than basic profile info
    // scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
  );

  /// Stream of authentication state changes.
  /// Emits a Firebase User object when the auth state changes (login/logout).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Gets the current authenticated Firebase User.
  /// Returns null if no user is authenticated.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in a user with their email and password.
  /// Returns the Firebase User object on success, throws FirebaseAuthException on failure.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException on signInWithEmailAndPassword: ${e.code} - ${e.message}');
      }
      rethrow; // Rethrow to be caught by the UI or provider
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error on signInWithEmailAndPassword: $e');
      }
      rethrow; // Rethrow for generic error handling
    }
  }

  /// Signs up a new user with their email and password.
  /// Returns the Firebase User object on success, throws FirebaseAuthException on failure.
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Send verification email after successful signup
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException on signUpWithEmailAndPassword: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error on signUpWithEmailAndPassword: $e');
      }
      rethrow;
    }
  }

  /// Signs in a user using their Google account.
  /// Returns the Firebase User object on success, null or throws on failure/cancellation.
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user cancelled the sign-in, googleUser will be null.
      if (googleUser == null) {
        if (kDebugMode) {
          print('Google sign-in cancelled by user.');
        }
        return null; // User cancelled the sign-in
      }

      // Show loading indicator
      if (kDebugMode) {
        print('Google sign-in successful, getting auth details...');
      }

      // Obtain the auth details from the request.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase.
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential.
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      // Get the user
      final User? user = userCredential.user;
      
      if (user != null) {
        // Update the user's display name if it's not set
        if (user.displayName == null || user.displayName!.isEmpty) {
          await user.updateDisplayName(googleUser.displayName);
        }
        
        // Update the user's photo URL if it's not set
        if (user.photoURL == null || user.photoURL!.isEmpty) {
          await user.updatePhotoURL(googleUser.photoUrl);
        }
        
        // Reload the user to get the updated profile
        await user.reload();
        return _firebaseAuth.currentUser;
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException on signInWithGoogle: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      // Handle other errors, e.g., network issues
      if (kDebugMode) {
        print('Unexpected error on signInWithGoogle: $e');
      }
      rethrow;
    }
  }

  /// Signs out the current user from Firebase and Google (if applicable).
  Future<void> signOut() async {
    try {
      // Check if the user signed in with Google
      bool signedInWithGoogle = _firebaseAuth.currentUser?.providerData
              .any((userInfo) => userInfo.providerId == GoogleAuthProvider.PROVIDER_ID) ??
          false;

      if (signedInWithGoogle) {
        // It's good practice to also sign out from Google to allow account switching.
        await _googleSignIn.signOut();
        if (kDebugMode) {
          print('Signed out from Google.');
        }
      }
      // Always sign out from Firebase.
      await _firebaseAuth.signOut();
      if (kDebugMode) {
        print('Signed out from Firebase.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign out: $e');
      }
      rethrow; // Rethrow to allow UI to handle error display
    }
  }

  /// Sends a password reset email to the given email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException on sendPasswordResetEmail: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error on sendPasswordResetEmail: $e');
      }
      rethrow;
    }
  }

  /// Updates the current user's display name.
  Future<void> updateUserDisplayName(String displayName) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(displayName);
        await user.reload(); // Reload user data to reflect changes
      } catch (e) {
        if (kDebugMode) {
          print('Error updating display name: $e');
        }
        rethrow;
      }
    }
  }

  /// Updates the current user's photo URL.
  Future<void> updateUserPhotoURL(String photoURL) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await user.updatePhotoURL(photoURL);
        await user.reload(); // Reload user data
      } catch (e) {
        if (kDebugMode) {
          print('Error updating photo URL: $e');
        }
        rethrow;
      }
    }
  }

  /// Sends a verification email to the current user.
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException on sendEmailVerification: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error on sendEmailVerification: $e');
      }
      rethrow;
    }
  }

  /// Checks if the current user's email is verified.
  bool isEmailVerified() {
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  /// Reloads the current user to get the latest verification status.
  Future<void> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException on reloadUser: ${e.code} - ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error on reloadUser: $e');
      }
      rethrow;
    }
  }
}
