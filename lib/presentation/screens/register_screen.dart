import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskly/app/theme/app_colors.dart';
import 'package:taskly/data/services/auth_service.dart';
import 'package:taskly/presentation/widgets/my_button.dart';
import 'package:taskly/presentation/widgets/my_text_field.dart';

class RegisterScreen extends StatelessWidget {
  final void Function()? onTap;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  RegisterScreen({super.key, required this.onTap});

  void register(BuildContext context) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords don\'t match', context);
      return;
    }
    final auth = AuthService();
    try {
      await auth.signUpWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showError('Password is too weak', context);
      } else if (e.code == 'email-already-in-use') {
        _showError('Account already exists for that email', context);
      } else {
        _showError(e.message ?? 'Registration failed', context);
      }
    } catch (e) {
      _showError(e.toString(), context);
    }
  }

  void _showError(String message, BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // App name
              Text(
                'Taskly',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Create your account',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              MyTextField(
                horizontalPadding: 20,
                hint: 'Email',
                obscureText: false,
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 10),

              MyTextField(
                horizontalPadding: 20,
                hint: 'Password',
                obscureText: true,
                controller: _passwordController,
                prefixIcon: Icons.lock_outlined,
              ),
              const SizedBox(height: 10),

              MyTextField(
                horizontalPadding: 20,
                hint: 'Confirm Password',
                obscureText: true,
                controller: _confirmPasswordController,
                prefixIcon: Icons.lock_outlined,
              ),
              const SizedBox(height: 20),

              MyButton(
                text: 'Register',
                onTap: () => register(context),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Login here',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}