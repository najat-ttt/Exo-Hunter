import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/cosmic_background.dart';

class AdminVerificationPage extends StatefulWidget {
  const AdminVerificationPage({super.key});

  @override
  State<AdminVerificationPage> createState() => _AdminVerificationPageState();
}

class _AdminVerificationPageState extends State<AdminVerificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String _selectedTab = 'pending'; // pending, verified, denied

  Future<void> _verifyScientist(String userId, Map<String, dynamic> scientistData, bool approve) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update scientist verification status
      await _firestore.collection('scientists').doc(userId).update({
        'verified': approve,
        'verificationStatus': approve ? 'approved' : 'denied',
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': FirebaseAuth.instance.currentUser?.uid,
      });

      // Send notification to scientist (you can implement email notification here)
      await _firestore.collection('notifications').doc().set({
        'userId': userId,
        'type': 'verification_update',
        'title': approve ? 'Account Verified!' : 'Verification Denied',
        'message': approve
          ? 'Congratulations! Your scientist account has been verified. You now have full access to research features.'
          : 'Your scientist verification request has been denied. Please contact support for more information.',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve ? '✅ Scientist verified successfully!' : '❌ Scientist verification denied',
            ),
            backgroundColor: approve ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
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
            content: Text('Error updating verification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildScientistCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final userId = doc.id;
    final name = data['name'] ?? 'Unknown';
    final email = data['email'] ?? 'No email';
    final institution = data['institution'] ?? 'No institution';
    final researchField = data['researchField'] ?? 'No field specified';
    final credentials = data['credentials'] ?? 'No credentials';
    final orcidId = data['orcidId'] ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final verified = data['verified'] ?? false;
    final verificationStatus = data['verificationStatus'] ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.midnightBlue.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(verificationStatus).withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.nebulaCyan,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(verificationStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(verificationStatus),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Institution and Research Field
            _buildInfoRow('Institution', institution, Icons.school),
            const SizedBox(height: 8),
            _buildInfoRow('Research Field', researchField, Icons.science),

            const SizedBox(height: 12),

            // Credentials
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cosmicPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.cosmicPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: AppTheme.supernovaOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Academic Credentials',
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
                    credentials,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ORCID ID if provided
            if (orcidId.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow('ORCID ID', orcidId, Icons.badge),
            ],

            // Registration date
            if (createdAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Registration Date',
                _formatDate(createdAt.toDate()),
                Icons.calendar_today
              ),
            ],

            // Action buttons for pending applications
            if (verificationStatus == 'pending') ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _showConfirmationDialog(
                        context,
                        userId,
                        data,
                        false,
                        'Deny Verification',
                        'Are you sure you want to deny this scientist\'s verification request?'
                      ),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Deny'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _showConfirmationDialog(
                        context,
                        userId,
                        data,
                        true,
                        'Approve Scientist',
                        'Are you sure you want to approve this scientist? They will gain full access to research features.'
                      ),
                      icon: const Icon(Icons.check, size: 20),
                      label: Text(_isLoading ? 'Processing...' : 'Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.nebulaCyan,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'verified': // Handle both status values
        return Colors.green;
      case 'denied':
        return Colors.red;
      default:
        return AppTheme.supernovaOrange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
      case 'verified': // Handle both status values
        return 'VERIFIED';
      case 'denied':
        return 'DENIED';
      default:
        return 'PENDING';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showConfirmationDialog(
    BuildContext context,
    String userId,
    Map<String, dynamic> data,
    bool approve,
    String title,
    String message
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.midnightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _verifyScientist(userId, data, approve);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: approve ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(approve ? 'Approve' : 'Deny'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scientist Verification',
          style: GoogleFonts.orbitron(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Tab selector
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.midnightBlue.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    _buildTabButton('pending', 'Pending', Icons.hourglass_empty),
                    _buildTabButton('verified', 'Verified', Icons.verified),
                    _buildTabButton('denied', 'Denied', Icons.cancel),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getScientistsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.inter(color: Colors.red),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.nebulaCyan,
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getEmptyIcon(),
                              size: 64,
                              color: Colors.white38,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getEmptyMessage(),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return _buildScientistCard(docs[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, String label, IconData icon) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.nebulaCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppTheme.midnightBlue : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.midnightBlue : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getScientistsStream() {
    Query query = _firestore.collection('scientists');

    switch (_selectedTab) {
      case 'verified':
        query = query.where('verified', isEqualTo: true);
        break;
      case 'denied':
        query = query.where('verificationStatus', isEqualTo: 'denied');
        break;
      default: // pending
        query = query.where('verificationStatus', isEqualTo: 'pending');
    }

    // Temporarily remove orderBy to avoid composite index issues
    return query.snapshots(includeMetadataChanges: true);
  }

  IconData _getEmptyIcon() {
    switch (_selectedTab) {
      case 'verified':
        return Icons.verified;
      case 'denied':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  String _getEmptyMessage() {
    switch (_selectedTab) {
      case 'verified':
        return 'No verified scientists yet.';
      case 'denied':
        return 'No denied applications.';
      default:
        return 'No pending scientist registrations.\nNew applications will appear here.';
    }
  }
}
