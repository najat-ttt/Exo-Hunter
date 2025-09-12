import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glowing_button.dart';

class ScientistForgotPasswordPage extends StatefulWidget {
  const ScientistForgotPasswordPage({super.key});

  @override
  State<ScientistForgotPasswordPage> createState() => _ScientistForgotPasswordPageState();
}

class _ScientistForgotPasswordPageState extends State<ScientistForgotPasswordPage> {
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
            content: Text('Password reset email sent! Please check your institutional email inbox.'),
            backgroundColor: AppTheme.cosmicPurple,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send reset email.';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No scientist account found with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid institutional email address.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many reset requests. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to send reset email.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
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
          'Reset Scientist Password',
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

                      // Icon
                      Icon(
                        Icons.science_outlined,
                        size: isDesktop ? 80 : 60,
                        color: AppTheme.cosmicPurple,
                      ),

                      SizedBox(height: isDesktop ? 24 : 16),

                      // Title
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
                        'Enter your institutional email to receive a password reset link.',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 18 : (isMobile ? 16 : 17),
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (isDesktop) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Make sure to check your university or research institution email.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white60,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      SizedBox(height: isDesktop ? 60 : 48),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Institutional Email Address',
                          hintText: 'scientist@university.edu',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.cosmicPurple,
                            size: isDesktop ? 24 : 20,
                          ),
                          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                          hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.cosmicPurple, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your institutional email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          // Suggest institutional email patterns
                          if (!value.contains('.edu') && !value.contains('.ac.') && !value.contains('.org')) {
                            return 'Please use your institutional email address';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isDesktop ? 40 : 32),

                      // Reset Button
                      SizedBox(
                        width: isDesktop ? 300 : (isMobile ? double.infinity : 280),
                        height: isDesktop ? 56 : 48,
                        child: GlowingButton(
                          onPressed: _isLoading ? null : _handlePasswordReset,
                          text: _isLoading ? 'Sending...' : 'Send Reset Link',
                          glowColor: AppTheme.cosmicPurple,
                          backgroundColor: AppTheme.cosmicPurple,
                        ),
                      ),

                      SizedBox(height: isDesktop ? 32 : 24),

                      // Additional Help Text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cosmicPurple.withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.cosmicPurple.withAlpha((0.3 * 255).toInt()),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppTheme.cosmicPurple,
                                  size: isDesktop ? 20 : 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Need Help?',
                                  style: GoogleFonts.inter(
                                    fontSize: isDesktop ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.cosmicPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Use your institutional email address (.edu, .ac.uk, etc.)\n'
                              '• Check your spam/junk folder if you don\'t receive the email\n'
                              '• Contact your IT department if you continue having issues',
                              style: GoogleFonts.inter(
                                fontSize: isDesktop ? 14 : 12,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isDesktop ? 32 : 24),

                      // Back to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Remember your password? ',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: isDesktop ? 14 : 12,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Back to Login',
                              style: GoogleFonts.inter(
                                color: AppTheme.cosmicPurple,
                                fontSize: isDesktop ? 14 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
