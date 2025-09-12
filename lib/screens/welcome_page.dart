import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'role_check_page.dart';
import '../widgets/glowing_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 768;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            // TODO: Replace with actual cosmic background image
            // image: AssetImage('assets/cosmic_bg.png'),
            image: NetworkImage('https://images.unsplash.com/photo-1446776877081-d282a0f896e2?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Dark overlay for better text readability
          decoration: BoxDecoration(
            color: AppTheme.midnightBlue.withAlpha((0.7 * 255).toInt()),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 800 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 48.0 : (isMobile ? 24.0 : 32.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // App Title
                      Text(
                        'Exo-Hunter',
                        style: GoogleFonts.orbitron(
                          fontSize: isDesktop ? 64 : (isMobile ? 48 : 56),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isDesktop ? 24 : 16),

                      // Subtitle
                      Text(
                        'Hunting Exoplanets with AI',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 24 : (isMobile ? 18 : 20),
                          color: AppTheme.nebulaCyan,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (isDesktop) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Discover worlds beyond our solar system using cutting-edge AI technology',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const Spacer(flex: 3),

                      // Continue Button with glow effect
                      SizedBox(
                        width: isDesktop ? 300 : (isMobile ? double.infinity : 280),
                        child: GlowingButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RoleCheckPage(),
                              ),
                            );
                          },
                          text: 'Continue',
                          glowColor: AppTheme.nebulaCyan,
                        ),
                      ),

                      const Spacer(flex: 1),
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