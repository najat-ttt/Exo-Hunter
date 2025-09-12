import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glowing_button.dart';
import 'login_page.dart';

class ScientistSignupPage extends StatefulWidget {
  const ScientistSignupPage({super.key});

  @override
  State<ScientistSignupPage> createState() => _ScientistSignupPageState();
}

class _ScientistSignupPageState extends State<ScientistSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _institutionController = TextEditingController();
  final _researchFieldController = TextEditingController();
  final _credentialsController = TextEditingController();
  final _orcidController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedResearchField;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final List<String> _researchFields = [
    'Astronomy',
    'Astrophysics',
    'Planetary Science',
    'Exoplanet Research',
    'Space Technology',
    'Observational Astronomy',
    'Theoretical Physics',
    'Data Science',
    'Machine Learning',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _institutionController.dispose();
    _researchFieldController.dispose();
    _credentialsController.dispose();
    _orcidController.dispose();
    super.dispose();
  }

  Future<void> _handleScientistSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check Firebase connection first
      print('🔥 Checking Firebase connection...');

      // Create Firebase Auth account
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('✅ Firebase Auth successful, UID: ${userCredential.user?.uid}');

      // Update display name
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // Store scientist data in Firestore with PENDING verification status
      print('💾 Attempting to save to Firestore...');

      await _saveToFirestoreWithRetry(userCredential.user!.uid);

      setState(() {
        _isLoading = false;
      });

      // Show success message with verification notice
      if (mounted) {
        _showVerificationPendingDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print('❌ Signup error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _saveToFirestoreWithRetry(String uid) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        // Try to enable network first
        try {
          await FirebaseFirestore.instance.enableNetwork();
          print('📡 Network enabled successfully');
        } catch (e) {
          print('⚠️ Network enable warning: $e');
        }

        // Use offline-first approach with cache and server
        await FirebaseFirestore.instance
            .collection('scientists')
            .doc(uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'institution': _institutionController.text.trim(),
          'researchField': _selectedResearchField ?? _researchFieldController.text.trim(),
          'credentials': _credentialsController.text.trim(),
          'orcidId': _orcidController.text.trim(),
          'role': 'scientist',
          'verified': false,
          'verificationStatus': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Use merge to handle offline scenarios

        print('✅ Successfully saved to Firestore');
        return; // Success, exit the retry loop

      } catch (e) {
        retryCount++;
        print('❌ Firestore save attempt $retryCount failed: $e');

        if (retryCount >= maxRetries) {
          // Instead of throwing an error, create a fallback mechanism
          print('⚠️ Firestore save failed, but continuing with auth-only registration');

          // Show a different success message indicating limited functionality
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Account Created (Limited Mode)',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your account was created but profile data may not be saved. Please try again later.',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return; // Don't throw error, just return
        }

        // Wait before retrying
        await Future.delayed(retryDelay);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() { _isLoading = false; });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Store scientist profile in Firestore
      await FirebaseFirestore.instance
          .collection('scientists')
          .doc(userCredential.user!.uid)
          .set({
        'name': userCredential.user?.displayName ?? 'Unknown',
        'email': userCredential.user?.email ?? '',
        'institution': _institutionController.text.trim(),
        'researchField': _selectedResearchField ?? _researchFieldController.text.trim(),
        'credentials': _credentialsController.text.trim(),
        'orcidId': _orcidController.text.trim(),
        'role': 'scientist',
        'verified': false,
        'verificationStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() { _isLoading = false; });

      if (mounted) {
        _showVerificationPendingDialog();
      }
    } catch (e) {
      setState(() { _isLoading = false; });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVerificationPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.midnightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Account Created!',
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎉 Your scientist account has been successfully created!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.supernovaOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.supernovaOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          color: AppTheme.supernovaOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pending Admin Verification',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.supernovaOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your account requires manual verification by our admin team. You can log in after approval (usually within 24-48 hours).',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'What happens next:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Admin reviews your credentials\n'
                '• You receive email notification\n'
                '• Login to access research tools',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Sign out the user since they can't access dashboard yet
                FirebaseAuth.instance.signOut();
                // Redirect to login page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Text(
                'Go to Login',
                style: GoogleFonts.inter(
                  color: AppTheme.nebulaCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 768;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scientist Registration',
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
                maxWidth: isDesktop ? 700 : double.infinity,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 48.0 : (isMobile ? 24.0 : 32.0)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isDesktop ? 20 : 10),

                      // Title
                      Text(
                        'Join as a\nResearch Scientist',
                        style: GoogleFonts.orbitron(
                          fontSize: isDesktop ? 32 : (isMobile ? 28 : 30),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isDesktop ? 12 : 6),

                      Text(
                        'Contribute to cutting-edge exoplanet research',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 18 : (isMobile ? 16 : 17),
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isDesktop ? 40 : 30),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Full Name*',
                          hintText: 'Dr. Jane Smith',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppTheme.nebulaCyan,
                            size: isDesktop ? 24 : 20,
                          ),
                          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                          hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Email Address*',
                          hintText: 'researcher@university.edu',
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
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Password*',
                          hintText: 'Create a strong password',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppTheme.nebulaCyan,
                            size: isDesktop ? 24 : 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                              size: isDesktop ? 24 : 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                          hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      // Institution Field
                      TextFormField(
                        controller: _institutionController,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Institution/Organization*',
                          hintText: 'Harvard University, NASA, ESA, etc.',
                          prefixIcon: Icon(
                            Icons.school_outlined,
                            color: AppTheme.nebulaCyan,
                            size: isDesktop ? 24 : 20,
                          ),
                          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                          hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your institution';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      // Research Field Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedResearchField,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14, color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Primary Research Field*',
                          prefixIcon: Icon(
                            Icons.science_outlined,
                            color: AppTheme.nebulaCyan,
                            size: isDesktop ? 24 : 20,
                          ),
                          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                        ),
                        dropdownColor: AppTheme.midnightBlue,
                        items: _researchFields.map((String field) {
                          return DropdownMenuItem<String>(
                            value: field,
                            child: Text(field),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedResearchField = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your research field';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      // Credentials Field
                      TextFormField(
                        controller: _credentialsController,
                        maxLines: 3,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Academic Credentials*',
                          hintText: 'Ph.D. in Astrophysics, Professor of Astronomy, etc.',
                          prefixIcon: Icon(
                            Icons.workspace_premium_outlined,
                            color: AppTheme.nebulaCyan,
                            size: isDesktop ? 24 : 20,
                          ),
                          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                          hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your credentials';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      // ORCID Field (Optional)
                      TextFormField(
                        controller: _orcidController,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'ORCID ID (Optional)',
                          hintText: '0000-0000-0000-0000',
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                            color: AppTheme.nebulaCyan,
                            size: isDesktop ? 24 : 20,
                          ),
                          labelStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                          hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
                        ),
                      ),

                      SizedBox(height: isDesktop ? 40 : 32),

                      // Signup Button
                      SizedBox(
                        width: isDesktop ? 350 : (isMobile ? double.infinity : 300),
                        height: isDesktop ? 56 : 48,
                        child: GlowingButton(
                          onPressed: _isLoading ? null : _handleScientistSignup,
                          text: _isLoading ? 'Creating Account...' : 'Register as Scientist',
                          glowColor: AppTheme.nebulaCyan,
                          backgroundColor: AppTheme.nebulaCyan,
                        ),
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      // Manual Verification Notice
                      Container(
                        padding: EdgeInsets.all(isDesktop ? 16 : 12),
                        decoration: BoxDecoration(
                          color: AppTheme.supernovaOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.supernovaOrange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  color: AppTheme.supernovaOrange,
                                  size: isDesktop ? 20 : 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Manual Verification Required',
                                  style: GoogleFonts.inter(
                                    fontSize: isDesktop ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.supernovaOrange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scientist accounts require manual verification. You\'ll receive access once your credentials are reviewed.',
                              style: GoogleFonts.inter(
                                fontSize: isDesktop ? 14 : 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      // Divider with "Or" text
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withAlpha((0.3 * 255).toInt()),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 12),
                            child: Text(
                              'Or',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: isDesktop ? 14 : 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withAlpha((0.3 * 255).toInt()),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isDesktop ? 32 : 24),

                      // Google Sign-In Button
                      SizedBox(
                        width: isDesktop ? 350 : (isMobile ? double.infinity : 300),
                        height: isDesktop ? 56 : 48,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: Icon(
                            Icons.g_mobiledata,
                            size: isDesktop ? 28 : 24,
                          ),
                          label: Text(
                            'Continue with Google',
                            style: GoogleFonts.inter(
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.midnightBlue,
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 16 : 12,
                              horizontal: isDesktop ? 24 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isDesktop ? 32 : 24),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: isDesktop ? 14 : 12,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Login Here',
                              style: GoogleFonts.inter(
                                color: AppTheme.nebulaCyan,
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
