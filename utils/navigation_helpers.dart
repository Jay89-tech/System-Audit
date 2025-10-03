import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'constants.dart';
import 'app_strings.dart';

class NavigationHelpers {
  // Navigate to screen
  static void navigateTo(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  // Navigate and replace current screen
  static void navigateReplace(BuildContext context, String route,
      {Object? extra}) {
    context.go(route, extra: extra);
  }

  // Navigate and push
  static void navigatePush(BuildContext context, String route,
      {Object? extra}) {
    context.push(route, extra: extra);
  }

  // Pop current screen
  static void pop(BuildContext context, {Object? result}) {
    if (context.canPop()) {
      context.pop(result);
    }
  }

  // Pop until specific route
  static void popUntil(BuildContext context, String route) {
    while (context.canPop()) {
      context.pop();
      if (GoRouter.of(context).location == route) {
        break;
      }
    }
  }

  // Navigate to splash
  static void navigateToSplash(BuildContext context) {
    context.go(AppRoutes.splash);
  }

  // Navigate to login
  static void navigateToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  // Navigate to dashboard
  static void navigateToDashboard(BuildContext context) {
    context.go(AppRoutes.dashboard);
  }

  // Navigate to profile
  static void navigateToProfile(BuildContext context) {
    context.push(AppRoutes.profile);
  }

  // Navigate to edit profile
  static void navigateToEditProfile(BuildContext context) {
    context.push(AppRoutes.editProfile);
  }

  // Navigate to qualifications
  static void navigateToQualifications(BuildContext context) {
    context.push(AppRoutes.qualifications);
  }

  // Navigate to add qualification
  static void navigateToAddQualification(BuildContext context) {
    context.push(AppRoutes.addQualification);
  }

  // Navigate to training
  static void navigateToTraining(BuildContext context) {
    context.push(AppRoutes.training);
  }

  // Navigate to notifications
  static void navigateToNotifications(BuildContext context) {
    context.push(AppRoutes.notifications);
  }

  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    String? title,
    required String message,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? AppStrings.error),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text(AppStrings.retry),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(onRetry != null ? AppStrings.cancel : AppStrings.close),
          ),
        ],
      ),
    );
  }

  // Show success dialog
  static Future<void> showSuccessDialog(
    BuildContext context, {
    String? title,
    required String message,
    VoidCallback? onClose,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? AppStrings.success),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClose?.call();
            },
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    String? title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? AppStrings.confirm),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  )
                : null,
            child: Text(confirmText ?? AppStrings.confirm),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // Show bottom sheet
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message ?? AppStrings.loading),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Show snackbar
  static void showSnackBar(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final color = _getSnackBarColor(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getSnackBarIcon(type), color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static Color _getSnackBarColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
      default:
        return Colors.blue;
    }
  }

  static IconData _getSnackBarIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
      default:
        return Icons.info;
    }
  }

  // Show date picker
  static Future<DateTime?> showDatePickerDialog(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime.now(),
      helpText: helpText,
    );
  }

  // Show time picker
  static Future<TimeOfDay?> showTimePickerDialog(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  // Check if can pop
  static bool canPop(BuildContext context) {
    return context.canPop();
  }

  // Get current route
  static String getCurrentRoute(BuildContext context) {
    return GoRouter.of(context).location;
  }
}

// Snackbar types
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

// Extension methods for easier navigation
extension NavigationExtension on BuildContext {
  void navigateTo(String route, {Object? extra}) {
    NavigationHelpers.navigateTo(this, route, extra: extra);
  }

  void navigatePush(String route, {Object? extra}) {
    NavigationHelpers.navigatePush(this, route, extra: extra);
  }

  void navigatePop({Object? result}) {
    NavigationHelpers.pop(this, result: result);
  }

  void showError(String message, {VoidCallback? onRetry}) {
    NavigationHelpers.showErrorDialog(this, message: message, onRetry: onRetry);
  }

  void showSuccess(String message, {VoidCallback? onClose}) {
    NavigationHelpers.showSuccessDialog(this,
        message: message, onClose: onClose);
  }

  Future<bool> showConfirm(String message,
      {String? title, bool isDangerous = false}) {
    return NavigationHelpers.showConfirmationDialog(
      this,
      message: message,
      title: title,
      isDangerous: isDangerous,
    );
  }

  void showSnack(String message, {SnackBarType type = SnackBarType.info}) {
    NavigationHelpers.showSnackBar(this, message: message, type: type);
  }

  void showLoading({String? message}) {
    NavigationHelpers.showLoadingDialog(this, message: message);
  }

  void hideLoading() {
    NavigationHelpers.hideLoadingDialog(this);
  }
}
