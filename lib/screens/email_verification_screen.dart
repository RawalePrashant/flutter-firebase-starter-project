import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResendingEmail = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Start a periodic check for email verification
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      await authProvider.reloadUser();
      if (authProvider.isEmailVerified()) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResendingEmail = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.sendEmailVerification();
      
      // Start countdown timer
      setState(() {
        _resendCountdown = 60;
      });
      
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending verification email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResendingEmail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Verify your email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent you an email verification link.\nPlease check your inbox and click the link to verify your email address.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: _isResendingEmail
                    ? 'Sending...'
                    : _resendCountdown > 0
                        ? 'Resend in $_resendCountdown seconds'
                        : 'Resend Verification Email',
                onPressed: () {
                  if (_resendCountdown == 0) {
                    _resendVerificationEmail();
                  }
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 