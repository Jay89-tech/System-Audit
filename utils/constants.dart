/// Application Constants
class AppConstants {
  // App Information
  static const String appName = 'Skills Audit';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Your Company';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String qualificationsCollection = 'qualifications';
  static const String trainingsCollection = 'trainings';
  static const String skillsCollection = 'skills';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String certificatesPath = 'certificates';

  // Notification Topics
  static const String allEmployeesTopic = 'all_employees';
  static const String adminTopic = 'admins';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxProfessionLength = 100;
  static const int minCellNumberLength = 10;
  static const int maxCellNumberLength = 15;

  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxCertificateSizeMB = 10;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedCertificateExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png'
  ];

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 5);

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Private constructor
  AppConstants._();
}

/// Route constants
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String qualifications = '/qualifications';
  static const String addQualification = '/qualifications/add';
  static const String editQualification = '/qualifications/edit';
  static const String training = '/training';
  static const String trainingDetail = '/training/detail';
  static const String skills = '/skills';
  static const String addSkill = '/skills/add';
  static const String notifications = '/notifications';

  // Private constructor
  AppRoutes._();
}

/// Asset path constants
class AssetPaths {
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String splashLogo = 'assets/images/splash_logo.png';
  static const String placeholderAvatar =
      'assets/images/placeholder_avatar.png';
  static const String emptyStateQualifications =
      'assets/images/empty_state_qualifications.png';
  static const String emptyStateTraining =
      'assets/images/empty_state_training.png';
  static const String emptyStateSkills = 'assets/images/empty_state_skills.png';

  // Icons
  static const String qualificationIcon = 'assets/icons/qualification_icon.png';
  static const String trainingIcon = 'assets/icons/training_icon.png';
  static const String skillIcon = 'assets/icons/skill_icon.png';
  static const String certificateIcon = 'assets/icons/certificate_icon.png';

  // Animations (Lottie)
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';

  // Private constructor
  AssetPaths._();
}
