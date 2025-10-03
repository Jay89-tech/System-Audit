import 'constants.dart';
import 'app_strings.dart';

class Validators {
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.invalidEmail;
    }

    return null;
  }

  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    if (value.length < AppConstants.minPasswordLength) {
      return AppStrings.passwordTooShort;
    }

    return null;
  }

  // Name Validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    if (value.trim().length < 2) {
      return AppStrings.nameInvalid;
    }

    if (value.trim().length > AppConstants.maxNameLength) {
      return 'Name is too long (max ${AppConstants.maxNameLength} characters)';
    }

    return null;
  }

  // Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < AppConstants.minCellNumberLength) {
      return AppStrings.invalidPhone;
    }

    if (digitsOnly.length > AppConstants.maxCellNumberLength) {
      return AppStrings.invalidPhone;
    }

    return null;
  }

  // Required Field Validation
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : AppStrings.fieldRequired;
    }
    return null;
  }

  // Number Validation
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    final number = int.tryParse(value);

    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return 'Value must be at least $min';
    }

    if (max != null && number > max) {
      return 'Value must be at most $max';
    }

    return null;
  }

  // Double Validation
  static String? validateDouble(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    final number = double.tryParse(value);

    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return 'Value must be at least $min';
    }

    if (max != null && number > max) {
      return 'Value must be at most $max';
    }

    return null;
  }

  // File Size Validation
  static bool validateFileSize(int fileSizeInBytes, int maxSizeMB) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeBytes;
  }

  // File Extension Validation
  static bool validateFileExtension(
      String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  // URL Validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Date Validation
  static String? validateDate(DateTime? date, {bool allowFuture = false}) {
    if (date == null) {
      return AppStrings.fieldRequired;
    }

    if (!allowFuture && date.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }

    return null;
  }

  // Profession Validation
  static String? validateProfession(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    if (value.trim().length < 2) {
      return 'Profession must be at least 2 characters';
    }

    if (value.trim().length > AppConstants.maxProfessionLength) {
      return 'Profession is too long (max ${AppConstants.maxProfessionLength} characters)';
    }

    return null;
  }

  // Experience Validation (in months)
  static String? validateExperience(String? value) {
    return validateNumber(value, min: 0, max: 600); // Max 50 years
  }

  // Institution Validation
  static String? validateInstitution(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Institution is required';
    }

    if (value.trim().length < 2) {
      return 'Institution name must be at least 2 characters';
    }

    return null;
  }

  // Qualification Validation
  static String? validateQualification(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Qualification is required';
    }

    if (value.trim().length < 2) {
      return 'Qualification must be at least 2 characters';
    }

    return null;
  }

  // Skill Name Validation
  static String? validateSkillName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Skill name is required';
    }

    if (value.trim().length < 2) {
      return 'Skill name must be at least 2 characters';
    }

    return null;
  }

  // Training Name Validation
  static String? validateTrainingName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Training name is required';
    }

    if (value.trim().length < 3) {
      return 'Training name must be at least 3 characters';
    }

    return null;
  }

  // Progress Validation (0-100)
  static String? validateProgress(double? value) {
    if (value == null) {
      return AppStrings.fieldRequired;
    }

    if (value < 0 || value > 100) {
      return 'Progress must be between 0 and 100';
    }

    return null;
  }
}

// Extension methods for easier validation
extension StringValidation on String? {
  bool get isValidEmail => Validators.validateEmail(this) == null;
  bool get isValidPhone => Validators.validatePhoneNumber(this) == null;
  bool get isValidName => Validators.validateName(this) == null;
  bool get isNotEmpty => this != null && this!.trim().isNotEmpty;
}

extension DateTimeValidation on DateTime? {
  bool get isValidDate => Validators.validateDate(this) == null;
  bool get isInPast => this != null && this!.isBefore(DateTime.now());
  bool get isInFuture => this != null && this!.isAfter(DateTime.now());
}
