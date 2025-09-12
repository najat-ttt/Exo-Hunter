import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glowing_button.dart';

class StudentExplorerDashboardPage extends StatefulWidget {
  const StudentExplorerDashboardPage({super.key});

  @override
  State<StudentExplorerDashboardPage> createState() => _StudentExplorerDashboardPageState();
}

class _StudentExplorerDashboardPageState extends State<StudentExplorerDashboardPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  final List<String> _navItems = [
    'Explore',
    'Learn',
    'Citizen Science',
    'Discoveries',
    'Community',
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;
    final isMobile = screenSize.width <= 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exoplanet Explorer',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {},
            ),
          ],
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Text('Profile', style: GoogleFonts.inter()),
              ),
              PopupMenuItem(
                value: 'achievements',
                child: Text('Achievements', style: GoogleFonts.inter()),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Text('Settings', style: GoogleFonts.inter()),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout', style: GoogleFonts.inter()),
              ),
            ],
          ),
        ],
      ),
      body: CosmicBackground(
        child: Row(
          children: [
            // Side Navigation (Desktop/Tablet only)
            if (!isMobile)
              Container(
                width: isDesktop ? 250 : 200,
                decoration: BoxDecoration(
                  color: AppTheme.midnightBlue.withAlpha((0.8 * 255).toInt()),
                  border: Border(
                    right: BorderSide(
                      color: AppTheme.supernovaOrange.withAlpha((0.3 * 255).toInt()),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // User Profile Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: isDesktop ? 40 : 30,
                            backgroundColor: AppTheme.supernovaOrange,
                            child: Icon(
                              Icons.explore,
                              size: isDesktop ? 40 : 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user?.displayName ?? 'Space Explorer',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            user?.email ?? 'explorer@email.com',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: isDesktop ? 12 : 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Level Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.nebulaCyan.withAlpha((0.3 * 255).toInt()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Level 3 Explorer',
                              style: GoogleFonts.inter(
                                color: AppTheme.nebulaCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    // Navigation Menu
                    Expanded(
                      child: ListView.builder(
                        itemCount: _navItems.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedIndex == index;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.supernovaOrange.withAlpha((0.3 * 255).toInt())
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getNavIcon(index),
                                color: isSelected ? AppTheme.supernovaOrange : Colors.white70,
                              ),
                              title: Text(
                                _navItems[index],
                                style: GoogleFonts.inter(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: isDesktop ? 14 : 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            // Main Content
            Expanded(
              child: _buildMainContent(isDesktop, isTablet, isMobile),
            ),
          ],
        ),
      ),
      // Bottom Navigation for Mobile
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppTheme.midnightBlue,
              selectedItemColor: AppTheme.supernovaOrange,
              unselectedItemColor: Colors.white70,
              selectedLabelStyle: GoogleFonts.inter(fontSize: 12),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
              items: _navItems.take(5).map((item) {
                final index = _navItems.indexOf(item);
                return BottomNavigationBarItem(
                  icon: Icon(_getNavIcon(index)),
                  label: item,
                );
              }).toList(),
            )
          : null,
    );
  }

  IconData _getNavIcon(int index) {
    switch (index) {
      case 0:
        return Icons.explore_outlined;
      case 1:
        return Icons.school_outlined;
      case 2:
        return Icons.volunteer_activism_outlined;
      case 3:
        return Icons.stars_outlined;
      case 4:
        return Icons.people_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildMainContent(bool isDesktop, bool isTablet, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Text(
            'Welcome, ${user?.displayName?.split(' ').first ?? 'Explorer'}!',
            style: GoogleFonts.orbitron(
              fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover the wonders of exoplanets and contribute to science',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),

          // Progress Stats Cards
          _buildProgressSection(isDesktop, isTablet, isMobile),

          const SizedBox(height: 32),

          // Main Content Based on Selected Nav
          _buildSelectedContent(isDesktop, isTablet, isMobile),
        ],
      ),
    );
  }

  Widget _buildProgressSection(bool isDesktop, bool isTablet, bool isMobile) {
    final stats = [
      {'title': 'Modules Completed', 'value': '7/12', 'icon': Icons.school, 'color': AppTheme.nebulaCyan, 'progress': 0.58},
      {'title': 'Discoveries Made', 'value': '3', 'icon': Icons.stars, 'color': AppTheme.supernovaOrange, 'progress': 1.0},
      {'title': 'Projects Joined', 'value': '2', 'icon': Icons.volunteer_activism, 'color': AppTheme.cosmicPurple, 'progress': 1.0},
      {'title': 'Community Points', 'value': '1,247', 'icon': Icons.emoji_events, 'color': AppTheme.nebulaCyan, 'progress': 0.76},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 2),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.3 : 1.1,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (stat['color'] as Color).withAlpha((0.3 * 255).toInt()),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat['icon'] as IconData,
                size: isDesktop ? 28 : 24,
                color: stat['color'] as Color,
              ),
              const SizedBox(height: 8),
              Text(
                stat['value'] as String,
                style: GoogleFonts.orbitron(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat['title'] as String,
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 11 : 9,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              if (stat['progress'] != null && stat['progress'] != 1.0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stat['progress'] as double,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(stat['color'] as Color),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedContent(bool isDesktop, bool isTablet, bool isMobile) {
    switch (_selectedIndex) {
      case 0:
        return _buildExploreContent(isDesktop, isTablet, isMobile);
      case 1:
        return _buildLearnContent(isDesktop, isTablet, isMobile);
      case 2:
        return _buildCitizenScienceContent(isDesktop, isTablet, isMobile);
      case 3:
        return _buildDiscoveriesContent(isDesktop, isTablet, isMobile);
      case 4:
        return _buildCommunityContent(isDesktop, isTablet, isMobile);
      default:
        return _buildExploreContent(isDesktop, isTablet, isMobile);
    }
  }

  Widget _buildExploreContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore the Universe',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildExploreCards(isDesktop, isTablet, isMobile),
        const SizedBox(height: 32),
        Text(
          'Featured Exoplanets',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeaturedPlanets(isDesktop, isTablet, isMobile),
      ],
    );
  }

  Widget _buildExploreCards(bool isDesktop, bool isTablet, bool isMobile) {
    final exploreCards = [
      {'title': '3D Solar Systems', 'description': 'Interactive 3D models of exoplanet systems', 'icon': Icons.threed_rotation, 'color': AppTheme.nebulaCyan},
      {'title': 'Virtual Observatory', 'description': 'Access real telescope data and images', 'icon': Icons.visibility, 'color': AppTheme.cosmicPurple},
      {'title': 'Planet Hunter', 'description': 'Help find new exoplanets in real data', 'icon': Icons.search, 'color': AppTheme.supernovaOrange},
      {'title': 'Atmosphere Analyzer', 'description': 'Learn about exoplanet atmospheres', 'icon': Icons.air, 'color': AppTheme.nebulaCyan},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 2.5 : 2.8,
      ),
      itemCount: exploreCards.length,
      itemBuilder: (context, index) {
        final card = exploreCards[index];
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${card['title']} - Coming Soon!'),
                backgroundColor: card['color'] as Color,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (card['color'] as Color).withAlpha((0.2 * 255).toInt()),
                  (card['color'] as Color).withAlpha((0.1 * 255).toInt()),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (card['color'] as Color).withAlpha((0.3 * 255).toInt()),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  card['icon'] as IconData,
                  size: isDesktop ? 40 : 32,
                  color: card['color'] as Color,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card['title'] as String,
                        style: GoogleFonts.orbitron(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card['description'] as String,
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedPlanets(bool isDesktop, bool isTablet, bool isMobile) {
    final planets = [
      {'name': 'Kepler-452b', 'distance': '1,402 ly', 'type': 'Super Earth', 'color': AppTheme.nebulaCyan},
      {'name': 'TRAPPIST-1e', 'distance': '40 ly', 'type': 'Terrestrial', 'color': AppTheme.cosmicPurple},
      {'name': 'K2-18b', 'distance': '124 ly', 'type': 'Sub-Neptune', 'color': AppTheme.supernovaOrange},
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: planets.length,
        itemBuilder: (context, index) {
          final planet = planets[index];
          return Container(
            width: isDesktop ? 280 : 220,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.05 * 255).toInt()),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (planet['color'] as Color).withAlpha((0.3 * 255).toInt()),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: planet['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planet['name'] as String,
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            planet['type'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 16,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      planet['distance'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Exploring ${planet['name']} - Coming Soon!'),
                          backgroundColor: planet['color'] as Color,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: planet['color'] as Color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Explore',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLearnContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Modules',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Master the science of exoplanet discovery and characterization.',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 24),
        _buildLearningModules(isDesktop, isTablet, isMobile),
      ],
    );
  }

  Widget _buildLearningModules(bool isDesktop, bool isTablet, bool isMobile) {
    final modules = [
      {'title': 'Introduction to Exoplanets', 'progress': 1.0, 'duration': '45 min', 'completed': true},
      {'title': 'Detection Methods', 'progress': 0.7, 'duration': '60 min', 'completed': false},
      {'title': 'Transit Photometry', 'progress': 0.3, 'duration': '90 min', 'completed': false},
      {'title': 'Radial Velocity', 'progress': 0.0, 'duration': '75 min', 'completed': false},
      {'title': 'Atmospheric Analysis', 'progress': 0.0, 'duration': '120 min', 'completed': false},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.05 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAlpha((0.1 * 255).toInt()),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (module['completed'] as bool)
                    ? AppTheme.nebulaCyan
                    : AppTheme.cosmicPurple.withAlpha((0.3 * 255).toInt()),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  (module['completed'] as bool) ? Icons.check : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['title'] as String,
                      style: GoogleFonts.orbitron(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module['duration'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: module['progress'] as double,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        (module['completed'] as bool) ? AppTheme.nebulaCyan : AppTheme.cosmicPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Starting ${module['title']} - Coming Soon!'),
                      backgroundColor: AppTheme.cosmicPurple,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (module['completed'] as bool)
                    ? AppTheme.nebulaCyan
                    : AppTheme.cosmicPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  (module['completed'] as bool) ? 'Review' : 'Continue',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCitizenScienceContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Citizen Science Projects',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Contribute to real scientific research and help discover new exoplanets.',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.05 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.volunteer_activism_outlined,
                size: 64,
                color: AppTheme.supernovaOrange,
              ),
              const SizedBox(height: 16),
              Text(
                'Citizen Science Projects Coming Soon',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Real research projects where you can contribute to exoplanet discovery will be available here.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveriesContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Discoveries',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Track your contributions to exoplanet science.',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.05 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.stars_outlined,
                size: 64,
                color: AppTheme.nebulaCyan,
              ),
              const SizedBox(height: 16),
              Text(
                'Discovery Tracking Coming Soon',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your personal discovery log and contribution tracking will be available here.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explorer Community',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connect with fellow space explorers and share your discoveries.',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.05 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: AppTheme.cosmicPurple,
              ),
              const SizedBox(height: 16),
              Text(
                'Community Features Coming Soon',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Forums, leaderboards, and social features for the explorer community will be available here.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
