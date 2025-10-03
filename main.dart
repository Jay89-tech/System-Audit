import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Controllers
import 'controllers/auth_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/qualification_controller.dart';
import 'controllers/training_controller.dart';

// Views
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/home/dashboard_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/qualifications/qualifications_screen.dart';
import 'views/training/training_screen.dart';

// Utilss
import 'utils/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SkillsAuditApp());
}

class SkillsAuditApp extends StatelessWidget {
  const SkillsAuditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => QualificationController()),
        ChangeNotifierProvider(create: (_) => TrainingController()),
      ],
      child: Consumer<AuthController>(
        builder: (context, authController, _) {
          return MaterialApp.router(
            title: 'Skills Audit System',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: _createRouter(authController),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthController authController) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isLoggedIn = authController.isLoggedIn;
        final isLoading = authController.isLoading;

        // Show splash while loading
        if (isLoading && state.matchedLocation == '/splash') {
          return '/splash';
        }

        // Redirect to login if not authenticated
        if (!isLoggedIn &&
            state.matchedLocation != '/login' &&
            state.matchedLocation != '/splash') {
          return '/login';
        }

        // Redirect to dashboard if authenticated and on login/splash
        if (isLoggedIn &&
            (state.matchedLocation == '/login' ||
                state.matchedLocation == '/splash')) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/qualifications',
          builder: (context, state) => const QualificationsScreen(),
        ),
        GoRoute(
          path: '/training',
          builder: (context, state) => const TrainingScreen(),
        ),
      ],
    );
  }
}
