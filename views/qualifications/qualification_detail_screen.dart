import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_strings.dart';

class QualificationDetailScreen extends StatelessWidget {
  final QualificationModel qualification;

  const QualificationDetailScreen({super.key, required this.qualification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qualification Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
              Navigator.of(
                context,
              ).pushNamed('/qualifications/edit', arguments: qualification);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.errorRed),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Status
            _buildHeaderCard(context),

            const SizedBox(height: 16),

            // Details Card
            _buildDetailsCard(context),

            const SizedBox(height: 16),

            // Certificate Card (if available)
            if (qualification.certificateUrl != null)
              _buildCertificateCard(context),

            const SizedBox(height: 16),

            // Status Information Card
            _buildStatusCard(context),

            const SizedBox(height: 16),

            // Timestamps Card
            _buildTimestampsCard(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepBlue, AppColors.blueAccent],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    qualification.qualification,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              qualification.institution,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
            if (qualification.completionDate != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Completed: ${DateFormat('MMMM yyyy').format(qualification.completionDate!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.8),
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

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData icon;

    switch (qualification.status) {
      case ApprovalStatus.approved:
        backgroundColor = AppColors.successGreen;
        textColor = AppColors.white;
        statusText = 'Approved';
        icon = Icons.check_circle;
        break;
      case ApprovalStatus.rejected:
        backgroundColor = AppColors.errorRed;
        textColor = AppColors.white;
        statusText = 'Rejected';
        icon = Icons.cancel;
        break;
      case ApprovalStatus.pending:
      default:
        backgroundColor = AppColors.warningOrange;
        textColor = AppColors.white;
        statusText = 'Pending';
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Qualification Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              context,
              icon: Icons.school,
              label: 'Institution',
              value: qualification.institution,
            ),
            const Divider(height: 32),
            _buildInfoRow(
              context,
              icon: Icons.workspace_premium,
              label: 'Qualification',
              value: qualification.qualification,
            ),
            if (qualification.completionDate != null) ...[
              const Divider(height: 32),
              _buildInfoRow(
                context,
                icon: Icons.calendar_month,
                label: 'Completion Date',
                value: DateFormat(
                  'dd MMMM yyyy',
                ).format(qualification.completionDate!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _openCertificate(qualification.certificateUrl!),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deepBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCertificateIcon(qualification.certificateUrl!),
                  color: AppColors.deepBlue,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certificate Attached',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view certificate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.mediumGrey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    if (qualification.status != ApprovalStatus.rejected ||
        qualification.rejectionReason == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.errorRed.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.errorRed, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Rejection Reason',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
              ),
              child: Text(
                qualification.rejectionReason!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please review and resubmit your qualification with the required information.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mediumGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            _buildTimelineItem(
              context,
              icon: Icons.add_circle_outline,
              label: 'Submitted',
              date: qualification.createdAt,
              isFirst: true,
            ),
            if (qualification.updatedAt != qualification.createdAt)
              _buildTimelineItem(
                context,
                icon: Icons.update,
                label: 'Last Updated',
                date: qualification.updatedAt,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.deepBlue, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.mediumGrey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required DateTime date,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(width: 2, height: 20, color: AppColors.softGrey),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.deepBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.deepBlue, size: 20),
            ),
            if (!isLast)
              Container(width: 2, height: 20, color: AppColors.softGrey),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: isFirst ? 0 : 20,
              bottom: isLast ? 0 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.mediumGrey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCertificateIcon(String url) {
    if (url.toLowerCase().contains('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (url.toLowerCase().contains('.jpg') ||
        url.toLowerCase().contains('.jpeg') ||
        url.toLowerCase().contains('.png')) {
      return Icons.image;
    }
    return Icons.description;
  }

  Future<void> _openCertificate(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Qualification'),
        content: Text(
          'Are you sure you want to delete "${qualification.qualification}" from ${qualification.institution}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return true to indicate deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
