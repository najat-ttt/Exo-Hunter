import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glowing_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Please check your inbox.'),
            backgroundColor: AppTheme.nebulaCyan,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to send reset email.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 768;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 500 : double.infinity,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 48.0 : (isMobile ? 24.0 : 32.0)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isDesktop ? 60 : 40),
                      Text(
                        'Forgot Your Password?',
                        style: GoogleFonts.orbitron(
                          fontSize: isDesktop ? 32 : (isMobile ? 28 : 30),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isDesktop ? 16 : 8),
                      Text(
                        'Enter your email to receive a password reset link.',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 18 : (isMobile ? 16 : 17),
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isDesktop ? 60 : 48),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your registered email',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.nebulaCyan,
                            size: isDesktop ? 24 : 20,
                          ),
                          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                          hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isDesktop ? 40 : 32),
                      SizedBox(
                        width: isDesktop ? 300 : (isMobile ? double.infinity : 280),
                        height: isDesktop ? 56 : 48,
                        child: GlowingButton(
                          onPressed: _isLoading ? null : _handlePasswordReset,
                          text: _isLoading ? 'Sending...' : 'Send Reset Link',
                          glowColor: AppTheme.supernovaOrange,
                          backgroundColor: AppTheme.supernovaOrange,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 40 : 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
