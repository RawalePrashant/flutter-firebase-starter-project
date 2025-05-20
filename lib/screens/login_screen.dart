// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart'; // For route names

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final success = await authProvider.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      // Navigation to HomeScreen is handled by AuthWrapper
    }
  }

  Future<void> _loginWithGoogle(AuthProvider authProvider) async {
    final success = await authProvider.signInWithGoogle();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Google Sign-In failed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    // Navigation to HomeScreen is handled by AuthWrapper
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false, // No back button on login
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // App Logo (Optional)
                Icon(Icons.lock_open_rounded, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 24.0),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32.0),

                // Email Text Field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Password Text Field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Login Button
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Login',
                        onPressed: () => _loginUser(authProvider),
                      ),
                const SizedBox(height: 16),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Google Sign-In Button
                CustomButton(
                  text: 'Sign in with Google',
                  onPressed: () => _loginWithGoogle(authProvider),
                  icon: Icons.g_mobiledata_outlined, // Using a generic Google icon
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  isOutlined: true,
                ),
                const SizedBox(height: 24.0),
                
                // "Or" divider
                Row(
                  children: <Widget>[
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR', style: TextStyle(color: Colors.grey[600])),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Sign Up Navigation
                TextButton(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[700]),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    // Clear any previous errors before navigating
                    authProvider.clearError();
                    Navigator.of(context).pushNamed(AppRouteNames.signup);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
