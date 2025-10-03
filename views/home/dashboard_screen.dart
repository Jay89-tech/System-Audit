import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final profileController =
        Provider.of<ProfileController>(context, listen: false);
    final qualificationController =
        Provider.of<QualificationController>(context, listen: false);
    final trainingController =
        Provider.of<TrainingController>(context, listen: false);

    // Load user data
    await Future.wait([
      qualificationController.loadQualifications(),
      trainingController.loadTrainings(),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _DashboardHomeView(),
          _ProfileView(),
          _QualificationsView(),
          _TrainingView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Qualifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Training',
          ),
        ],
      ),
    );
  }
}

class _DashboardHomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Consumer<AuthController>(
            builder: (context, authController, _) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutDialog(context, authController);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.errorRed),
                        SizedBox(width: 8),
                        Text('Sign Out'),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: AppColors.deepBlue,
                    child: Text(
                      authController.currentUser?.name.isNotEmpty == true
                          ? authController.currentUser!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dashboard data
          await Future.wait([
            Provider.of<QualificationController>(context, listen: false)
                .loadQualifications(),
            Provider.of<TrainingController>(context, listen: false)
                .loadTrainings(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 16),
              _buildQuickStats(),
              const SizedBox(height: 16),
              _buildRecentActivity(),
              const SizedBox(height: 16),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;
        return Card(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.deepBlue,
                  AppColors.blueAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.profession ?? 'Professional',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Qualifications',
            '0',
            Icons.school,
            AppColors.successGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Trainings',
            '0',
            Icons.trending_up,
            AppColors.warningOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '0',
            Icons.check_circle,
            AppColors.deepBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppColors.softGrey,
                ),
                const SizedBox(height: 8),
                Text(
                  'No recent activity',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your recent qualifications and training updates will appear here',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Qualification',
                Icons.add_circle_outline,
                () => context.go('/qualifications'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'View Training',
                Icons.play_circle_outline,
                () => context.go('/training'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: AppColors.deepBlue,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

// Placeholder views for other tabs
class _ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile View - Coming Soon'),
      ),
    );
  }
}

class _QualificationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Qualifications View - Coming Soon'),
      ),
    );
  }
}

class _TrainingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Training View - Coming Soon'),
      ),
    );
  }
}
