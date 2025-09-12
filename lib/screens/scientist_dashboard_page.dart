import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glowing_button.dart';

class ScientistDashboardPage extends StatefulWidget {
  const ScientistDashboardPage({super.key});

  @override
  State<ScientistDashboardPage> createState() => _ScientistDashboardPageState();
}

class _ScientistDashboardPageState extends State<ScientistDashboardPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  final List<String> _navItems = [
    'Dashboard',
    'Research',
    'Data Analysis',
    'Publications',
    'Collaborations',
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
          'Scientist Portal',
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
              icon: const Icon(Icons.settings_outlined),
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
                      color: AppTheme.cosmicPurple.withAlpha((0.3 * 255).toInt()),
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
                            backgroundColor: AppTheme.cosmicPurple,
                            child: Icon(
                              Icons.science,
                              size: isDesktop ? 40 : 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user?.displayName ?? 'Dr. Scientist',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            user?.email ?? 'scientist@university.edu',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: isDesktop ? 12 : 10,
                            ),
                            textAlign: TextAlign.center,
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
                                  ? AppTheme.cosmicPurple.withAlpha((0.3 * 255).toInt())
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getNavIcon(index),
                                color: isSelected ? AppTheme.cosmicPurple : Colors.white70,
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
              selectedItemColor: AppTheme.cosmicPurple,
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
        return Icons.dashboard_outlined;
      case 1:
        return Icons.science_outlined;
      case 2:
        return Icons.analytics_outlined;
      case 3:
        return Icons.article_outlined;
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
            'Welcome back, ${user?.displayName?.split(' ').first ?? 'Doctor'}!',
            style: GoogleFonts.orbitron(
              fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continue your exoplanet research and discoveries',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),

          // Quick Stats Cards
          _buildStatsSection(isDesktop, isTablet, isMobile),

          const SizedBox(height: 32),

          // Main Content Based on Selected Nav
          _buildSelectedContent(isDesktop, isTablet, isMobile),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDesktop, bool isTablet, bool isMobile) {
    final stats = [
      {'title': 'Active Projects', 'value': '12', 'icon': Icons.folder_open, 'color': AppTheme.nebulaCyan},
      {'title': 'Exoplanets Found', 'value': '47', 'icon': Icons.public, 'color': AppTheme.cosmicPurple},
      {'title': 'Publications', 'value': '8', 'icon': Icons.article, 'color': AppTheme.supernovaOrange},
      {'title': 'Collaborators', 'value': '23', 'icon': Icons.people, 'color': AppTheme.nebulaCyan},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 2),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.5 : 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(20),
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
                size: isDesktop ? 32 : 28,
                color: stat['color'] as Color,
              ),
              const SizedBox(height: 12),
              Text(
                stat['value'] as String,
                style: GoogleFonts.orbitron(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat['title'] as String,
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 12 : 10,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedContent(bool isDesktop, bool isTablet, bool isMobile) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent(isDesktop, isTablet, isMobile);
      case 1:
        return _buildResearchContent(isDesktop, isTablet, isMobile);
      case 2:
        return _buildAnalysisContent(isDesktop, isTablet, isMobile);
      case 3:
        return _buildPublicationsContent(isDesktop, isTablet, isMobile);
      case 4:
        return _buildCollaborationsContent(isDesktop, isTablet, isMobile);
      default:
        return _buildDashboardContent(isDesktop, isTablet, isMobile);
    }
  }

  Widget _buildDashboardContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityList(isDesktop, isTablet, isMobile),
        const SizedBox(height: 32),
        Text(
          'Quick Actions',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickActions(isDesktop, isTablet, isMobile),
      ],
    );
  }

  Widget _buildActivityList(bool isDesktop, bool isTablet, bool isMobile) {
    final activities = [
      {'title': 'New exoplanet candidate detected in Kepler data', 'time': '2 hours ago', 'type': 'discovery'},
      {'title': 'Collaboration request from Dr. Smith', 'time': '4 hours ago', 'type': 'collaboration'},
      {'title': 'Paper "Atmospheric Analysis of K2-18b" published', 'time': '1 day ago', 'type': 'publication'},
      {'title': 'Data analysis completed for TRAPPIST-1 system', 'time': '2 days ago', 'type': 'analysis'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.05 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha((0.1 * 255).toInt()),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.white.withAlpha((0.1 * 255).toInt()),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Icon(
              _getActivityIcon(activity['type'] as String),
              color: AppTheme.cosmicPurple,
            ),
            title: Text(
              activity['title'] as String,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: isDesktop ? 14 : 12,
              ),
            ),
            subtitle: Text(
              activity['time'] as String,
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: isDesktop ? 12 : 10,
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'discovery':
        return Icons.explore;
      case 'collaboration':
        return Icons.people;
      case 'publication':
        return Icons.article;
      case 'analysis':
        return Icons.analytics;
      default:
        return Icons.info;
    }
  }

  Widget _buildQuickActions(bool isDesktop, bool isTablet, bool isMobile) {
    final actions = [
      {'title': 'Start New Research', 'icon': Icons.add_circle_outline, 'color': AppTheme.nebulaCyan},
      {'title': 'Upload Data', 'icon': Icons.cloud_upload, 'color': AppTheme.cosmicPurple},
      {'title': 'Run Analysis', 'icon': Icons.play_circle_outline, 'color': AppTheme.supernovaOrange},
      {'title': 'Create Report', 'icon': Icons.description, 'color': AppTheme.nebulaCyan},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 2),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 2 : 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GlowingButton(
          onPressed: () {
            // TODO: Implement action functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${action['title']} - Coming Soon!'),
                backgroundColor: action['color'] as Color,
              ),
            );
          },
          text: action['title'] as String,
          glowColor: action['color'] as Color,
          backgroundColor: action['color'] as Color,
        );
      },
    );
  }

  Widget _buildResearchContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Research Projects',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Manage your ongoing exoplanet research projects and datasets.',
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
                Icons.science_outlined,
                size: 64,
                color: AppTheme.cosmicPurple,
              ),
              const SizedBox(height: 16),
              Text(
                'Research Tools Coming Soon',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Advanced research tools and project management features will be available here.',
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

  Widget _buildAnalysisContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Analysis Tools',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Analyze exoplanet data with advanced AI-powered tools.',
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
                Icons.analytics_outlined,
                size: 64,
                color: AppTheme.supernovaOrange,
              ),
              const SizedBox(height: 16),
              Text(
                'AI Analysis Tools Coming Soon',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Machine learning models for exoplanet detection and characterization will be available here.',
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

  Widget _buildPublicationsContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Publications & Papers',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Manage your research publications and draft new papers.',
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
                Icons.article_outlined,
                size: 64,
                color: AppTheme.nebulaCyan,
              ),
              const SizedBox(height: 16),
              Text(
                'Publication Management Coming Soon',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tools for managing research papers, citations, and collaborative writing will be available here.',
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

  Widget _buildCollaborationsContent(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collaborations',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connect with other scientists and manage collaborative projects.',
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
                'Collaboration Tools Coming Soon',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Networking and collaboration features for the global scientific community will be available here.',
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
