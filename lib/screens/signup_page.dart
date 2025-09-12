import 'package:exo_hunter/screens/student_explorer_dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glowing_button.dart';
import 'student_login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // TODO: Integrate with Firebase Auth or API
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase email/password sign-up
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful!'),
            backgroundColor: AppTheme.nebulaCyan,
          ),
        );
        // Navigate to Student Explorer Dashboard
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
          content: Text(e.message ?? 'Signup failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // TODO: Integrate Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 Starting Google Sign-In process...');

      // Configure GoogleSignIn with additional scopes and serverClientId
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '128278022719-b0ei6tdpl012o0nppcl1d4t8cr4891qa.apps.googleusercontent.com',
        scopes: [
          'email',
          'profile',
          'openid',
        ],
      );

      // Clear any cached sign-in state to ensure fresh authentication
      await googleSignIn.signOut();

      print('🔄 Initiating Google Sign-In...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        setState(() { _isLoading = false; });
        return; // User cancelled
      }

      print('✅ Google Sign-In successful!');
      print('📧 User email: ${googleUser.email}');
      print('👤 Display name: ${googleUser.displayName}');
      print('🔐 Getting authentication details...');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('🎟️ Access Token: ${googleAuth.accessToken != null ? "✅ Present" : "❌ Missing"}');
      print('🆔 ID Token: ${googleAuth.idToken != null ? "✅ Present" : "❌ Missing"}');

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw Exception('❌ Critical: No authentication tokens received from Google');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔥 Signing in to Firebase with Google credentials...');
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      print('🎉 Firebase sign-in successful!');
      print('🆔 User ID: ${userCredential.user?.uid}');
      print('📧 Firebase email: ${userCredential.user?.email}');
      print('👤 Firebase display name: ${userCredential.user?.displayName}');

      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Welcome ${userCredential.user?.displayName ?? userCredential.user?.email}!'),
            backgroundColor: AppTheme.supernovaOrange,
            duration: const Duration(seconds: 3),
          ),
        );
        // Navigate to Student Explorer Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentExplorerDashboardPage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase Auth Error: ${e.code} - ${e.message}');
      setState(() { _isLoading = false; });

      String errorMessage = 'Authentication failed';
      String errorIcon = '❌';

      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with a different sign-in method.';
          errorIcon = '⚠️';
          break;
        case 'invalid-credential':
          errorMessage = 'The credential is invalid or expired.';
          errorIcon = '🔐';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google Sign-In is not enabled for this app.';
          errorIcon = '🚫';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          errorIcon = '🔒';
          break;
        default:
          if (e.message?.toLowerCase().contains('people api') == true) {
            errorMessage = '🛠️ Google People API needs to be enabled in Google Cloud Console.';
            errorIcon = '⚙️';
          } else {
            errorMessage = e.message ?? 'Authentication failed';
          }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorIcon $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Try Email',
            textColor: Colors.white,
            onPressed: () {
              // Focus on email field as alternative
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ),
      );
    } catch (e) {
      print('💥 General Error: $e');
      setState(() { _isLoading = false; });

      String errorMessage = 'Sign-in failed';
      String errorIcon = '❌';

      if (e.toString().toLowerCase().contains('people api') ||
          e.toString().toLowerCase().contains('service_disabled')) {
        errorMessage = '🛠️ Google People API is not enabled. Please enable it in Google Cloud Console or use email signup.';
        errorIcon = '⚙️';
      } else if (e.toString().toLowerCase().contains('network')) {
        errorMessage = '🌐 Network error. Please check your internet connection.';
        errorIcon = '📡';
      } else {
        errorMessage = 'Unexpected error: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorIcon $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Use Email',
            textColor: Colors.white,
            onPressed: () {
              // Suggest using email signup instead
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('💡 Try creating an account with email and password above'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
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
          'Join Exo-Hunter',
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
                maxWidth: isDesktop ? 600 : double.infinity,
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
                        'Join the\nExoplanet Hunt!',
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
                        'Discover worlds beyond our solar system',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 18 : (isMobile ? 16 : 17),
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isDesktop ? 50 : 40),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
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
                            return 'Please enter your name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
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
                          labelText: 'Email Address',
                          hintText: 'explorer@email.com',
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

                      SizedBox(height: isDesktop ? 40 : 32),

                      // Signup Button
                      SizedBox(
                        width: isDesktop ? 300 : (isMobile ? double.infinity : 280),
                        height: isDesktop ? 56 : 48,
                        child: GlowingButton(
                          onPressed: _isLoading ? null : _handleSignup,
                          text: _isLoading ? 'Creating Account...' : 'Create Account',
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
                        width: isDesktop ? 300 : (isMobile ? double.infinity : 280),
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
                                  builder: (context) => const StudentLoginPage(),
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
