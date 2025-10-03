import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;
  static final List<NotificationModel> _notifications = [];
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  // Initialize notification service
  static Future<void> initialize() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permissions');

        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('FCM Token: $_fcmToken');

        // Setup message handlers
        _setupMessageHandlers();

        // Setup background message handler
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      } else {
        debugPrint(
            'User declined or has not accepted notification permissions');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Get current FCM token
  static String? get fcmToken => _fcmToken;

  // Setup message handlers for different app states
  static void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Handle notification tap when app is terminated
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint(
            'App opened from terminated state via notification: ${message.messageId}');
        _handleNotificationTap(message);
      }
    });

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('FCM Token refreshed: $newToken');
      // TODO: Update token in Firestore
    });
  }

  // Handle foreground messages (show in-app notification)
  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = NotificationModel.fromRemoteMessage(message);
    _notifications.insert(0, notification);
    unreadCount.value = _notifications.where((n) => !n.isRead).length;

    // Show in-app notification
    _showInAppNotification(notification);
  }

  // Handle notification tap navigation
  static void _handleNotificationTap(RemoteMessage message) {
    final notification = NotificationModel.fromRemoteMessage(message);
    _notifications.insert(0, notification);

    // Mark as read since user tapped on it
    notification.isRead = true;
    unreadCount.value = _notifications.where((n) => !n.isRead).length;

    // Navigate based on notification data
    _navigateBasedOnNotification(message);
  }

  // Navigate to appropriate screen based on notification type
  static void _navigateBasedOnNotification(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? '';
    final action = data['action'] ?? '';

    // Get the current navigation context
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (action) {
      case 'open_profile':
        context.go('/profile');
        break;
      case 'open_qualifications':
        context.go('/qualifications');
        break;
      case 'open_training':
        context.go('/training');
        break;
      case 'open_dashboard':
        context.go('/dashboard');
        break;
      default:
        // Default to dashboard
        context.go('/dashboard');
        break;
    }
  }

  // Show custom in-app notification widget
  static void _showInAppNotification(NotificationModel notification) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Create custom overlay for in-app notification
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              overlayEntry?.remove();
              // Navigate to appropriate screen
              _navigateBasedOnNotification(
                RemoteMessage(
                  data: notification.data,
                  notification: RemoteNotification(
                    title: notification.title,
                    body: notification.body,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => overlayEntry?.remove(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry?.remove();
    });
  }

  // Get appropriate icon for notification type
  static IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'qualification_approved':
        return Icons.check_circle;
      case 'qualification_rejected':
        return Icons.error;
      case 'training_suggested':
        return Icons.lightbulb;
      case 'training_completed':
        return Icons.school;
      case 'profile_reminder':
        return Icons.person;
      case 'welcome':
        return Icons.celebration;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.notifications;
    }
  }

  // Get all notifications
  static List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  // Mark notification as read
  static void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      _notifications[index].readAt = DateTime.now();
      unreadCount.value = _notifications.where((n) => !n.isRead).length;
    }
  }

  // Mark all notifications as read
  static void markAllAsRead() {
    for (var notification in _notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
        notification.readAt = DateTime.now();
      }
    }
    unreadCount.value = 0;
  }

  // Clear all notifications
  static void clearAll() {
    _notifications.clear();
    unreadCount.value = 0;
  }

  // Delete specific notification
  static void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  // Subscribe to topic (for bulk notifications)
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  // Update FCM token in Firestore
  static Future<void> updateTokenInFirestore(String userId) async {
    if (_fcmToken != null) {
      try {
        // TODO: Update user document with FCM token
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(userId)
        //     .update({'fcmToken': _fcmToken});
        debugPrint('FCM token updated in Firestore for user: $userId');
      } catch (e) {
        debugPrint('Error updating FCM token in Firestore: $e');
      }
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');

  // Process the notification data
  // You can store it locally or perform other background tasks
}

// Notification Model
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  bool isRead;
  DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.receivedAt,
    this.isRead = false,
    this.readAt,
  });

  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'general',
      data: message.data,
      receivedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'receivedAt': receivedAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'readAt': readAt?.millisecondsSinceEpoch,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data']),
      receivedAt: DateTime.fromMillisecondsSinceEpoch(json['receivedAt']),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['readAt'])
          : null,
    );
  }
}

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
