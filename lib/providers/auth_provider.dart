// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// AuthProvider manages the authentication state of the application.
/// It uses AuthService to interact with Firebase and notifies listeners of changes.
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  UserModel? _user; // The current authenticated user
  bool _isLoading = false; // Tracks loading state for UI updates
  String? _errorMessage; // Stores error messages for UI display

  AuthProvider(this._authService) {
    // Listen to authentication state changes from AuthService.
    _authService.authStateChanges.listen(_onAuthStateChanged);
    // Initialize user state.
    _user = _authService.currentUser != null
        ? UserModel.fromFirebaseUser(_authService.currentUser!)
        : null;
  }

  // Getter for the current user.
  UserModel? get user => _user;

  // Getter for the loading state.
  bool get isLoading => _isLoading;

  // Getter for error messages.
  String? get errorMessage => _errorMessage;

  // Stream of authentication state changes from Firebase.
  Stream<UserModel?> get authStateChanges =>
      _authService.authStateChanges.map((firebaseUser) =>
          firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser) : null);


  // Callback for when Firebase auth state changes.
  void _onAuthStateChanged(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _user = UserModel.fromFirebaseUser(firebaseUser);
    }
    // Clear loading and error states on auth change.
    _isLoading = false;
    _errorMessage = null;
    notifyListeners(); // Notify widgets listening to this provider.
  }

  // Helper method to handle common auth operation logic.
  Future<bool> _performAuthOperation(Future<firebase_auth.User?> Function() operation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final firebaseUser = await operation();
      if (firebaseUser != null) {
        _user = UserModel.fromFirebaseUser(firebaseUser);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "An unknown error occurred.";
      if (kDebugMode) {
        print("FirebaseAuthException: ${e.code} - ${e.message}");
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred: ${e.toString()}";
      if (kDebugMode) {
        print("Unexpected error: ${e.toString()}");
      }
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Signs in a user with email and password.
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    return _performAuthOperation(() => _authService.signInWithEmailAndPassword(email, password));
  }

  /// Signs up a new user with email and password.
  Future<bool> signUpWithEmailAndPassword(String email, String password, {String? displayName}) async {
    return _performAuthOperation(() async {
      final user = await _authService.signUpWithEmailAndPassword(email, password);
      if (user != null && displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        // Re-fetch the user to get the updated display name
        await user.reload();
        return firebase_auth.FirebaseAuth.instance.currentUser;
      }
      return user;
    });
  }

  /// Signs in a user with Google.
  Future<bool> signInWithGoogle() async {
    return _performAuthOperation(() => _authService.signInWithGoogle());
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
      _user = null; // Explicitly set user to null on sign out.
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error signing out: ${e.toString()}";
      if (kDebugMode) {
        print("Error signing out: $e");
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Sends a verification email to the current user.
  Future<void> sendEmailVerification() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      _errorMessage = "Error sending verification email: ${e.toString()}";
      if (kDebugMode) {
        print("Error sending verification email: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Checks if the current user's email is verified.
  bool isEmailVerified() {
    return _authService.isEmailVerified();
  }

  /// Reloads the current user to get the latest verification status.
  Future<void> reloadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.reloadUser();
      // Update the user model after reload
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        _user = UserModel.fromFirebaseUser(currentUser);
      }
    } catch (e) {
      _errorMessage = "Error reloading user: ${e.toString()}";
      if (kDebugMode) {
        print("Error reloading user: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sends a password reset email to the given email address.
  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _errorMessage = "Error sending password reset email: ${e.toString()}";
      if (kDebugMode) {
        print("Error sending password reset email: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears any displayed error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
