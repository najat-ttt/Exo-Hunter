import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glowing_button.dart';
import 'forgot_password_page.dart';
import 'student_explorer_dashboard_page.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back, Explorer!'),
            backgroundColor: AppTheme.supernovaOrange,
          ),
        );
        // Navigate to student/explorer dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentExplorerDashboardPage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '128278022719-b0ei6tdpl012o0nppcl1d4t8cr4891qa.apps.googleusercontent.com',
        scopes: ['email', 'profile', 'openid'],
      );

      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

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

      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${userCredential.user?.displayName ?? userCredential.user?.email}!'),
            backgroundColor: AppTheme.supernovaOrange,
            duration: const Duration(seconds: 3),
          ),
        );
        // Navigate to student/explorer dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentExplorerDashboardPage(),
          ),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
          'Student & Explorer Login',
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

                      // Title
                      Text(
                        'Welcome Back,\nExplorer!',
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
                        'Continue your cosmic journey of discovery',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 18 : (isMobile ? 16 : 17),
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isDesktop ? 60 : 48),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'student@school.edu',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.supernovaOrange,
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
                            color: AppTheme.supernovaOrange,
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
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isDesktop ? 16 : 12),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              color: AppTheme.supernovaOrange,
                              fontSize: isDesktop ? 14 : 12,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isDesktop ? 40 : 32),

                      // Login Button
                      SizedBox(
                        height: isDesktop ? 56 : 48,
                        child: GlowingButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          text: _isLoading ? 'Logging In...' : 'Login',
                          glowColor: AppTheme.supernovaOrange,
                          backgroundColor: AppTheme.supernovaOrange,
                        ),
                      ),

                      SizedBox(height: isDesktop ? 32 : 24),

                      // Divider
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

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: isDesktop ? 14 : 12,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Go back to role selection
                            },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.inter(
                                color: AppTheme.supernovaOrange,
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
