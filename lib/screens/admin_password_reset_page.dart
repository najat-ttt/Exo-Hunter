import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';

/// Admin Password Reset Utility
/// Use this to reset your admin password when you forget it
class AdminPasswordResetPage extends StatefulWidget {
  const AdminPasswordResetPage({super.key});

  @override
  State<AdminPasswordResetPage> createState() => _AdminPasswordResetPageState();
}

class _AdminPasswordResetPageState extends State<AdminPasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with the known admin email
    _emailController.text = 'sheikhsiamnajat@gmail.com';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ Password Reset Email Sent!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check your email for reset instructions.',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Failed to send reset email';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No admin account found with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to send reset email';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
          'Admin Password Reset',
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
                      SizedBox(height: isDesktop ? 40 : 20),

                      // Title
                      Text(
                        _emailSent ? 'Email Sent!' : 'Reset Admin Password',
                        style: GoogleFonts.orbitron(
                          fontSize: isDesktop ? 32 : (isMobile ? 28 : 30),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isDesktop ? 12 : 6),

                      Text(
                        _emailSent
                          ? 'Check your email for password reset instructions'
                          : 'Enter your admin email to receive reset instructions',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 18 : (isMobile ? 16 : 17),
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isDesktop ? 40 : 30),

                      if (!_emailSent) ...[
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: isDesktop ? 16 : 14),
                          decoration: InputDecoration(
                            labelText: 'Admin Email Address',
                            hintText: 'sheikhsiamnajat@gmail.com',
                            prefixIcon: Icon(
                              Icons.admin_panel_settings,
                              color: AppTheme.nebulaCyan,
                              size: isDesktop ? 24 : 20,
                            ),
                            labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                            hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your admin email';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isDesktop ? 32 : 24),

                        // Reset Button
                        SizedBox(
                          height: isDesktop ? 56 : 48,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _sendPasswordResetEmail,
                            icon: Icon(
                              _isLoading ? Icons.hourglass_empty : Icons.email_outlined,
                              size: isDesktop ? 24 : 20,
                            ),
                            label: Text(
                              _isLoading ? 'Sending...' : 'Send Reset Email',
                              style: GoogleFonts.inter(
                                fontSize: isDesktop ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.supernovaOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Success state
                        Container(
                          padding: EdgeInsets.all(isDesktop ? 24 : 16),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.mark_email_read,
                                size: isDesktop ? 64 : 48,
                                color: Colors.green,
                              ),
                              SizedBox(height: isDesktop ? 16 : 12),
                              Text(
                                'Password reset email sent to:',
                                style: GoogleFonts.inter(
                                  fontSize: isDesktop ? 16 : 14,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: isDesktop ? 8 : 4),
                              Text(
                                _emailController.text.trim(),
                                style: GoogleFonts.inter(
                                  fontSize: isDesktop ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isDesktop ? 32 : 24),

                        // Resend button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _emailSent = false;
                            });
                          },
                          child: Text(
                            'Send Another Reset Email',
                            style: GoogleFonts.inter(
                              color: AppTheme.nebulaCyan,
                              fontSize: isDesktop ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: isDesktop ? 24 : 20),

                      // Instructions
                      Container(
                        padding: EdgeInsets.all(isDesktop ? 16 : 12),
                        decoration: BoxDecoration(
                          color: AppTheme.nebulaCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.nebulaCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppTheme.nebulaCyan,
                                  size: isDesktop ? 20 : 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Next Steps',
                                  style: GoogleFonts.inter(
                                    fontSize: isDesktop ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.nebulaCyan,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1. Check your email inbox\n'
                              '2. Click the password reset link\n'
                              '3. Set a new secure password\n'
                              '4. Return to login page and sign in\n'
                              '5. You\'ll be redirected to admin dashboard',
                              style: GoogleFonts.inter(
                                fontSize: isDesktop ? 14 : 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isDesktop ? 32 : 24),

                      // Back to login button
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back to Login',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: isDesktop ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
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
