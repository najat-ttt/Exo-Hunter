import 'package:exo_hunter/screens/scientist_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'signup_page.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glowing_button.dart';

class RoleCheckPage extends StatelessWidget {
  const RoleCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 768;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 600 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48.0 : (isMobile ? 24.0 : 32.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Question Title
                    Text(
                      'Are you a Scientist?',
                      style: GoogleFonts.orbitron(
                        fontSize: isDesktop ? 40 : (isMobile ? 32 : 36),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isDesktop ? 24 : 16),

                    // Subtitle
                    Text(
                      'Choose your path in the cosmic journey',
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 20 : (isMobile ? 16 : 18),
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (isDesktop) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Scientists have access to advanced research tools and datasets,\nwhile explorers can participate in citizen science projects.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white60,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    SizedBox(height: isDesktop ? 80 : 60),

                    // Buttons Container
                    if (isDesktop) ...[
                      // Desktop: Side by side layout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 220,
                              child: GlowingButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ScientistSignupPage(),
                                    ),
                                  );
                                },
                                text: 'Yes, I\'m a Scientist',
                                glowColor: AppTheme.cosmicPurple,
                                backgroundColor: AppTheme.cosmicPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: SizedBox(
                              width: 220,
                              child: GlowingButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignupPage(),
                                    ),
                                  );
                                },
                                text: 'No, I\'m a Student/Explorer',
                                glowColor: AppTheme.supernovaOrange,
                                backgroundColor: AppTheme.supernovaOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Mobile/Tablet: Stacked layout
                      SizedBox(
                        width: isMobile ? double.infinity : 350,
                        child: GlowingButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScientistSignupPage(),
                              ),
                            );
                          },
                          text: 'Yes, I\'m a Scientist',
                          glowColor: AppTheme.cosmicPurple,
                          backgroundColor: AppTheme.cosmicPurple,
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: isMobile ? double.infinity : 350,
                        child: GlowingButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupPage(),
                              ),
                            );
                          },
                          text: 'Student/Explorer',
                          glowColor: AppTheme.supernovaOrange,
                          backgroundColor: AppTheme.supernovaOrange,
                        ),
                      ),
                    ],

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}