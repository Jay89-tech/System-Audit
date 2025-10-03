import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';
import '../../controllers/qualification_controller.dart';

class QualificationsScreen extends StatefulWidget {
  const QualificationsScreen({super.key});

  @override
  State<QualificationsScreen> createState() => _QualificationsScreenState();
}

class _QualificationsScreenState extends State<QualificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadQualifications();
  }

  Future<void> _loadQualifications() async {
    final qualificationController =
        Provider.of<QualificationController>(context, listen: false);
    await qualificationController.loadQualifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Qualifications'),
        actions: [
          IconButton(
            onPressed: () => _showAddQualificationDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQualifications,
        child: Consumer<QualificationController>(
          builder: (context, controller, _) {
            if (controller.isLoading && controller.qualifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.qualifications.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.qualifications.length,
              itemBuilder: (context, index) {
                final qualification = controller.qualifications[index];
                return _buildQualificationCard(qualification);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddQualificationDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: AppColors.softGrey,
            ),
            const SizedBox(height: 24),
            Text(
              'No Qualifications Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add your educational qualifications and certifications to showcase your expertise.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddQualificationDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Qualification'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificationCard(QualificationModel qualification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        qualification.qualification,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        qualification.institution,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(qualification.status),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleMenuAction(value, qualification),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (qualification.certificateUrl != null)
                      const PopupMenuItem(
                        value: 'view_cert',
                        child: Row(
                          children: [
                            Icon(Icons.description, size: 20),
                            SizedBox(width: 8),
                            Text('View Certificate'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              size: 20, color: AppColors.errorRed),
                          SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(color: AppColors.errorRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (qualification.completionDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: AppColors.mediumGrey),
                  const SizedBox(width: 8),
                  Text(
                    'Completed: ${DateFormat('MMM yyyy').format(qualification.completionDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                  ),
                ],
              ),
            ],
            if (qualification.status == ApprovalStatus.rejected &&
                qualification.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.errorRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason: ${qualification.rejectionReason}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.errorRed,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (qualification.certificateUrl != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.attachment,
                      size: 16, color: AppColors.mediumGrey),
                  const SizedBox(width: 8),
                  Text(
                    'Certificate attached',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
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

  Widget _buildStatusBadge(ApprovalStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case ApprovalStatus.approved:
        color = AppColors.successGreen;
        text = 'Approved';
        icon = Icons.check_circle;
        break;
      case ApprovalStatus.rejected:
        color = AppColors.errorRed;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
      case ApprovalStatus.pending:
      default:
        color = AppColors.warningOrange;
        text = 'Pending';
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, QualificationModel qualification) {
    switch (action) {
      case 'edit':
        _showEditQualificationDialog(qualification);
        break;
      case 'view_cert':
        // TODO: Implement certificate viewer
        _showCertificateViewer(qualification.certificateUrl!);
        break;
      case 'delete':
        _showDeleteConfirmation(qualification);
        break;
    }
  }

  void _showAddQualificationDialog() {
    _showQualificationDialog();
  }

  void _showEditQualificationDialog(QualificationModel qualification) {
    _showQualificationDialog(qualification: qualification);
  }

  void _showQualificationDialog({QualificationModel? qualification}) {
    showDialog(
      context: context,
      builder: (context) => _QualificationFormDialog(
        qualification: qualification,
        onSave: (institution, qualificationName, completionDate) async {
          final authController =
              Provider.of<AuthController>(context, listen: false);
          final qualificationController =
              Provider.of<QualificationController>(context, listen: false);

          bool success;
          if (qualification != null) {
            success = await qualificationController.updateQualification(
              qualificationId: qualification.id,
              institution: institution,
              qualification: qualificationName,
              completionDate: completionDate,
            );
          } else {
            success = await qualificationController.addQualification(
              userId: authController.currentUser!.uid,
              institution: institution,
              qualification: qualificationName,
              completionDate: completionDate,
            );
          }

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(qualification != null
                    ? 'Qualification updated successfully'
                    : 'Qualification added successfully'),
                backgroundColor: AppColors.successGreen,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    qualificationController.errorMessage ?? 'Operation failed'),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        },
      ),
    );
  }

  void _showCertificateViewer(String url) {
    // TODO: Implement certificate viewer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certificate viewer coming soon'),
        backgroundColor: AppColors.warningOrange,
      ),
    );
  }

  void _showDeleteConfirmation(QualificationModel qualification) {
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
            onPressed: () async {
              Navigator.pop(context);

              final qualificationController =
                  Provider.of<QualificationController>(context, listen: false);
              final success = await qualificationController
                  .deleteQualification(qualification.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Qualification deleted successfully'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(qualificationController.errorMessage ??
                        'Failed to delete qualification'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
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

class _QualificationFormDialog extends StatefulWidget {
  final QualificationModel? qualification;
  final Function(
          String institution, String qualification, DateTime? completionDate)
      onSave;

  const _QualificationFormDialog({
    this.qualification,
    required this.onSave,
  });

  @override
  State<_QualificationFormDialog> createState() =>
      _QualificationFormDialogState();
}

class _QualificationFormDialogState extends State<_QualificationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _qualificationController = TextEditingController();
  DateTime? _completionDate;

  @override
  void initState() {
    super.initState();
    if (widget.qualification != null) {
      _institutionController.text = widget.qualification!.institution;
      _qualificationController.text = widget.qualification!.qualification;
      _completionDate = widget.qualification!.completionDate;
    }
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.qualification != null
          ? 'Edit Qualification'
          : 'Add Qualification'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(
                  labelText: 'Institution',
                  hintText: 'e.g., University of Cape Town',
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Institution is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(
                  labelText: 'Qualification',
                  hintText: 'e.g., Bachelor of Science in Computer Science',
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Qualification is required' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Completion Date (Optional)',
                  ),
                  child: Text(
                    _completionDate != null
                        ? DateFormat('MMM yyyy').format(_completionDate!)
                        : 'Select completion date',
                    style: TextStyle(
                      color: _completionDate != null
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<QualificationController>(
                builder: (context, controller, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Certificate (Optional)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.mediumGrey,
                                  ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: controller.selectCertificate,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Select File'),
                          ),
                        ],
                      ),
                      if (controller.selectedCertificate != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description,
                                  color: AppColors.deepBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.selectedCertificate!.name,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              IconButton(
                                onPressed: controller.clearSelectedCertificate,
                                icon: const Icon(Icons.close, size: 16),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        Consumer<QualificationController>(
          builder: (context, controller, _) {
            return ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(
                          _institutionController.text.trim(),
                          _qualificationController.text.trim(),
                          _completionDate,
                        );
                        Navigator.pop(context);
                      }
                    },
              child: controller.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.qualification != null ? 'Update' : 'Add'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _completionDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: 'Select completion date',
    );

    if (picked != null && picked != _completionDate) {
      setState(() {
        _completionDate = picked;
      });
    }
  }
}
