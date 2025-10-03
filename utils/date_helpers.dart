import 'package:intl/intl.dart';

class DateHelpers {
  // Standard date format: Jan 15, 2024
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Short date format: 15/01/2024
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Long date format: January 15, 2024
  static String formatDateLong(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  // Time format: 14:30
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Date and time: Jan 15, 2024 14:30
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  // Full date time: January 15, 2024 at 2:30 PM
  static String formatDateTimeFull(DateTime date) {
    return DateFormat('MMMM dd, yyyy \'at\' h:mm a').format(date);
  }

  // Month and year: January 2024
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Short month and year: Jan 2024
  static String formatMonthYearShort(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  // Relative time (e.g., "2 hours ago", "yesterday")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? "minute" : "minutes"} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? "hour" : "hours"} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? "month" : "months"} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? "year" : "years"} ago';
    }
  }

  // Time ago (short version): 2h, 3d, 1w
  static String formatTimeAgoShort(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Check if date is this year
  static bool isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week
  static DateTime startOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysToSubtract)));
  }

  // Get end of week
  static DateTime endOfWeek(DateTime date) {
    final daysToAdd = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToAdd)));
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  // Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  // Calculate age from date of birth
  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Calculate experience in years and months
  static String calculateExperience(int months) {
    if (months < 12) {
      return '$months ${months == 1 ? "month" : "months"}';
    }
    
    final years = (months / 12).floor();
    final remainingMonths = months % 12;
    
    if (remainingMonths == 0) {
      return '$years ${years == 1 ? "year" : "years"}';
    }
    
    return '$years ${years == 1 ? "year" : "years"} $remainingMonths ${remainingMonths == 1 ? "month" : "months"}';
  }

  // Parse date string
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? "day" : "days"}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${duration.inHours == 1 ? "hour" : "hours"}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} ${duration.inMinutes == 1 ? "minute" : "minutes"}';
    } else {
      return '${duration.inSeconds} ${duration.inSeconds == 1 ? "second" : "seconds"}';
    }
  }

  // Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = startOfDay(from);
    final toDate = startOfDay(to);
    return toDate.difference(fromDate).inDays;
  }

  // Add business days (excluding weekends)
  static DateTime addBusinessDays(DateTime date, int days) {
    DateTime result = date;
    int addedDays = 0;
    
    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday && result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }
    
    return result;
  }

  // Check if date is weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  // Get day name
  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Get month name
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  // Format date for API (ISO 8601)
  static String formatForApi(DateTime date) {
    return date.toIso8601String();
  }

  // Format date range
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return formatDate(start);
    } else if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('dd, yyyy').format(end)}';
    } else if (start.year == end.year) {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}';
    } else {
      return '${formatDate(start)} - ${formatDate(end)}';
    }
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}

// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  bool get isToday => DateHelpers.isToday(this);
  bool get isYesterday => DateHelpers.isYesterday(this);
  bool get isThisWeek => DateHelpers.isThisWeek(this);
  bool get isThisMonth => DateHelpers.isThisMonth(this);
  bool get isThisYear => DateHelpers.isThisYear(this);
  bool get isWeekend => DateHelpers.isWeekend(this);
  
  String get formatted => DateHelpers.formatDate(this);
  String get formattedShort => DateHelpers.formatDateShort(this);
  String get formattedLong => DateHelpers.formatDateLong(this);
  String get formattedTime => DateHelpers.formatTime(this);
  String get formattedDateTime => DateHelpers.formatDateTime(this);
  String get relativeTime => DateHelpers.formatRelativeTime(this);
  String get timeAgo => DateHelpers.formatTimeAgoShort(this);
  
  DateTime get startOfDay => DateHelpers.startOfDay(this);
  DateTime get endOfDay => DateHelpers.endOfDay(this);
  DateTime get startOfWeek => DateHelpers.startOfWeek(this);
  DateTime get endOfWeek => DateHelpers.endOfWeek(this);
  DateTime get startOfMonth => DateHelpers.startOfMonth(this);
  DateTime get endOfMonth => DateHelpers.endOfMonth(this);
  
  int daysBetween(DateTime other) => DateHelpers.daysBetween(this, other);
}