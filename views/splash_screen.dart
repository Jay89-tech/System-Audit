import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Initialize authentication state
    final authController = Provider.of<AuthController>(context, listen: false);

    // Minimum splash duration for branding
    await Future.delayed(const Duration(seconds: 3));

    // Check authentication status
    await authController.checkAuthStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white,
              AppColors.lightGrey,
              AppColors.softGrey.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo/Icon Container
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.deepBlue,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.deepBlue.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.assignment_ind_outlined,
                                  size: 60,
                                  color: AppColors.white,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // App Title
                              Text(
                                'Skills Audit',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                              ),

                              const SizedBox(height: 8),

                              // Subtitle
                              Text(
                                'Professional Development System',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.mediumGrey,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading Indicator
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SpinKitThreeBounce(
                      color: AppColors.deepBlue,
                      size: 30.0,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading your workspace...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                    ),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      width: 60,
                      color: AppColors.softGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Empowering Professional Growth',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGrey,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
