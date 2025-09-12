import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glowing_button.dart';
import 'scientist_forgot_password_page.dart';
import 'scientist_dashboard_page.dart';
import 'admin_verification_page.dart';
import 'admin_password_reset_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Starting login process...');

      // Firebase email/password sign-in
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('✅ Firebase Auth successful, UID: ${userCredential.user?.uid}');

      // Check user role with retry mechanism
      final String userRole = await _getUserRoleWithRetry(userCredential.user!.uid);

      if (mounted) {
        // Route user based on their role
        if (userRole == 'admin') {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '👨‍💼 Welcome Admin! Redirecting to verification dashboard...',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.nebulaCyan,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminVerificationPage(),
            ),
          );
        } else if (userRole == 'scientist') {
          // Check if scientist is verified
          final isVerified = await _checkScientistVerification(userCredential.user!.uid);

          setState(() {
            _isLoading = false;
          });

          if (!isVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ Your account is pending verification. Please contact admin.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
            // Sign out the user since they can't access dashboard yet
            await FirebaseAuth.instance.signOut();
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🔬 Welcome back to your research portal!',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.supernovaOrange,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ScientistDashboardPage(),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });

          // Unknown role - treat as regular user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ Account role not recognized. Please contact support.',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );

          // Sign out the user
          await FirebaseAuth.instance.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
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

      print('❌ Login error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Error',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unable to verify account. Please check your connection.',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _handleLogin(),
            ),
          ),
        );
      }
    }
  }

  Future<String> _getUserRoleWithRetry(String uid) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        print('🔍 Checking user role, attempt ${retryCount + 1}...');
        print('🔍 Firebase Auth UID: $uid');

        final currentUser = FirebaseAuth.instance.currentUser;
        print('🔍 Current user email: ${currentUser?.email}');

        // First check if user is an admin by UID
        print('🔍 Checking admin collection by UID...');
        try {
          final adminDoc = await FirebaseFirestore.instance
              .collection('admins')
              .doc(uid)
              .get();

          print('🔍 Admin doc by UID exists: ${adminDoc.exists}');
          if (adminDoc.exists) {
            print('✅ Admin role confirmed by UID');
            print('🔍 Admin data: ${adminDoc.data()}');
            return 'admin';
          }
        } catch (e) {
          print('❌ Error checking admin by UID: $e');
        }

        // Fallback: Check admins by email query (for robustness)
        if (currentUser?.email != null) {
          print('🔍 Checking admin by email query: ${currentUser!.email}');

          try {
            final adminQueryByEmail = await FirebaseFirestore.instance
                .collection('admins')
                .where('email', isEqualTo: currentUser.email)
                .limit(1)
                .get();

            print('🔍 Admin query by email found ${adminQueryByEmail.docs.length} documents');
            if (adminQueryByEmail.docs.isNotEmpty) {
              print('✅ Admin role confirmed by email query');
              final foundDoc = adminQueryByEmail.docs.first;
              print('🔍 Found admin document ID: ${foundDoc.id}');
              print('🔍 Found admin data: ${foundDoc.data()}');
              return 'admin';
            }
          } catch (e) {
            print('❌ Error checking admin by email: $e');
          }
        }

        // Check if user is a scientist
        print('🔍 Checking scientist collection...');
        try {
          final scientistDoc = await FirebaseFirestore.instance
              .collection('scientists')
              .doc(uid)
              .get();

          print('🔍 Scientist doc exists: ${scientistDoc.exists}');
          if (scientistDoc.exists) {
            print('✅ Scientist role confirmed');
            final scientistData = scientistDoc.data()!;
            print('🔍 Scientist data: $scientistData');
            print('🔍 Verified status: ${scientistData['verified']}');
            print('🔍 Verification status: ${scientistData['verificationStatus']}');
            print('🔍 Role field: ${scientistData['role']}');
            return 'scientist';
          } else {
            print('❌ Scientist document does not exist for UID: $uid');
          }
        } catch (e) {
          print('❌ Error checking scientist collection: $e');
        }

        // Check users collection as fallback
        print('🔍 Checking users collection...');
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final role = userData['role'] ?? 'user';
            print('✅ User role found: $role');
            return role;
          } else {
            print('❌ User document does not exist in users collection');
          }
        } catch (e) {
          print('❌ Error checking users collection: $e');
        }

        print('⚠️ No role found for user after checking all collections');

        // If we reach here and it's not the last retry, continue to retry
        if (retryCount < maxRetries - 1) {
          print('🔄 Retrying role check...');
          retryCount++;
          await Future.delayed(retryDelay);
          continue;
        }

        return 'unknown';

      } catch (e) {
        retryCount++;
        print('❌ Role check attempt $retryCount failed: $e');
        print('❌ Error type: ${e.runtimeType}');
        print('❌ Stack trace: ${StackTrace.current}');

        if (retryCount >= maxRetries) {
          print('❌ Failed to get user role after $maxRetries attempts');
          return 'unknown';
        }

        await Future.delayed(retryDelay);
      }
    }

    return 'unknown';
  }

  Future<bool> _checkScientistVerification(String uid) async {
    try {
      print('🔍 Starting scientist verification check for UID: $uid');

      final scientistDoc = await FirebaseFirestore.instance
          .collection('scientists')
          .doc(uid)
          .get();

      if (scientistDoc.exists) {
        final data = scientistDoc.data()!;
        final verified = data['verified'];
        final verificationStatus = data['verificationStatus'];

        print('🔍 Scientist verification check:');
        print('   - verified: $verified (type: ${verified.runtimeType})');
        print('   - verificationStatus: $verificationStatus (type: ${verificationStatus.runtimeType})');
        print('   - Full data: $data');

        // More robust verification check
        bool isApproved = false;

        // Check if verified field is true (boolean)
        if (verified is bool && verified == true) {
          isApproved = true;
          print('   - Approved via verified field (boolean true)');
        }

        // Also check if verificationStatus is "approved"
        if (verificationStatus is String && verificationStatus == 'approved') {
          isApproved = true;
          print('   - Approved via verificationStatus field ("approved")');
        }

        // Additional check for legacy data where verified might be a string
        if (verified is String && verified.toLowerCase() == 'true') {
          isApproved = true;
          print('   - Approved via verified field (string "true")');
        }

        print('   - Final isApproved: $isApproved');
        return isApproved;
      } else {
        print('❌ Scientist document does not exist for UID: $uid');
      }
    } catch (e) {
      print('❌ Error checking scientist verification: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 768;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
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

                      // Login Title
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.orbitron(
                          fontSize: isDesktop ? 32 : (isMobile ? 28 : 30),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isDesktop ? 12 : 6),

                      Text(
                        'Access your research portal',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 18 : (isMobile ? 16 : 17),
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isDesktop ? 40 : 30),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'your.email@domain.com',
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
                          labelText: 'Password',
                          hintText: 'Enter your password',
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
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isDesktop ? 32 : 24),

                      // Login Button
                      SizedBox(
                        height: isDesktop ? 56 : 48,
                        child: GlowingButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          text: _isLoading ? 'Logging in...' : 'Login',
                          glowColor: AppTheme.nebulaCyan,
                          backgroundColor: AppTheme.nebulaCyan,
                        ),
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      // Forgot Password Link
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScientistForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              color: AppTheme.nebulaCyan,
                              fontSize: isDesktop ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isDesktop ? 32 : 24),

                      // Admin Login Notice
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
                                  Icons.admin_panel_settings,
                                  color: AppTheme.nebulaCyan,
                                  size: isDesktop ? 20 : 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Admin Access',
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
                              'Admins will be automatically redirected to the verification dashboard upon login.',
                              style: GoogleFonts.inter(
                                fontSize: isDesktop ? 14 : 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AdminPasswordResetPage(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.vpn_key,
                                  size: isDesktop ? 18 : 16,
                                  color: AppTheme.supernovaOrange,
                                ),
                                label: Text(
                                  'Forgot Admin Password?',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.supernovaOrange,
                                    fontSize: isDesktop ? 14 : 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
