import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: NotificationService.unreadCount,
            builder: (context, unreadCount, _) {
              if (unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () {
                    setState(() {
                      NotificationService.markAllAsRead();
                    });
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 8),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: NotificationService.unreadCount,
        builder: (context, unreadCount, _) {
          final notifications = NotificationService.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppColors.softGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.mediumGrey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you receive notifications, they\'ll appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mediumGrey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: AppColors.white,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          NotificationService.deleteNotification(notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead ? AppColors.white : AppColors.lightGrey,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              setState(() {
                NotificationService.markAsRead(notification.id);
              });
            }
            // Handle notification tap navigation
            _handleNotificationTap(notification);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.deepBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTimestamp(notification.receivedAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.mediumGrey,
                                    ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification.type)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getNotificationTypeLabel(notification.type),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getNotificationColor(notification.type),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    final action = notification.data['action'] ?? '';

    switch (action) {
      case 'open_profile':
        Navigator.of(context).pushNamed('/profile');
        break;
      case 'open_qualifications':
        Navigator.of(context).pushNamed('/qualifications');
        break;
      case 'open_training':
        Navigator.of(context).pushNamed('/training');
        break;
      case 'open_dashboard':
        Navigator.of(context).pushNamed('/dashboard');
        break;
      default:
        // Stay on notifications screen
        break;
    }
  }

  IconData _getNotificationIcon(String type) {
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
      case 'admin_reminder':
        return Icons.admin_panel_settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'qualification_approved':
      case 'training_completed':
        return AppColors.successGreen;
      case 'qualification_rejected':
        return AppColors.errorRed;
      case 'training_suggested':
      case 'profile_reminder':
        return AppColors.warningOrange;
      case 'welcome':
        return AppColors.deepBlue;
      case 'maintenance':
        return AppColors.mediumGrey;
      default:
        return AppColors.deepBlue;
    }
  }

  String _getNotificationTypeLabel(String type) {
    switch (type) {
      case 'qualification_approved':
        return 'APPROVED';
      case 'qualification_rejected':
        return 'ATTENTION';
      case 'training_suggested':
        return 'TRAINING';
      case 'training_completed':
        return 'COMPLETED';
      case 'profile_reminder':
        return 'REMINDER';
      case 'welcome':
        return 'WELCOME';
      case 'maintenance':
        return 'SYSTEM';
      default:
        return 'INFO';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text(
            'This will permanently delete all notifications. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                NotificationService.clearAll();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
