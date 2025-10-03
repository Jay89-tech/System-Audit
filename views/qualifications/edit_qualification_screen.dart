import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/qualification_controller.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_strings.dart';
import '../../utils/validators.dart';
import '../../utils/app_colors.dart';

class EditQualificationScreen extends StatefulWidget {
  final QualificationModel qualification;

  const EditQualificationScreen({
    super.key,
    required this.qualification,
  });

  @override
  State<EditQualificationScreen> createState() =>
      _EditQualificationScreenState();
}

class _EditQualificationScreenState extends State<EditQualificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _institutionController;
  late TextEditingController _qualificationController;
  DateTime? _completionDate;
  PlatformFile? _selectedCertificate;

  @override
  void initState() {
    super.initState();
    _institutionController =
        TextEditingController(text: widget.qualification.institution);
    _qualificationController =
        TextEditingController(text: widget.qualification.qualification);
    _completionDate = widget.qualification.completionDate;
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _completionDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: AppStrings.completionDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.deepBlue,
              onPrimary: AppColors.white,
              onSurface: AppColors.darkGrey,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _completionDate) {
      setState(() {
        _completionDate = picked;
      });
    }
  }

  Future<void> _selectCertificate() async {
    final qualificationController =
        Provider.of<QualificationController>(context, listen: false);
    await qualificationController.selectCertificate();

    setState(() {
      _selectedCertificate = qualificationController.selectedCertificate;
    });
  }

  Future<void> _updateQualification() async {
    if (_formKey.currentState!.validate()) {
      final qualificationController =
          Provider.of<QualificationController>(context, listen: false);

      final success = await qualificationController.updateQualification(
        qualificationId: widget.qualification.id,
        institution: _institutionController.text.trim(),
        qualification: _qualificationController.text.trim(),
        completionDate: _completionDate,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.qualificationUpdated),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(qualificationController.errorMessage ??
                AppStrings.genericError),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editQualification),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Banner (if rejected)
              if (widget.qualification.status == ApprovalStatus.rejected) ...[
                Card(
                  color: AppColors.errorRedTransparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.errorRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Qualification Rejected',
                              style: TextStyle(
                                color: AppColors.errorRed,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (widget.qualification.rejectionReason != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Reason: ${widget.qualification.rejectionReason}',
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Please update the information and resubmit.',
                          style: TextStyle(
                            color: AppColors.mediumGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Current Status
              if (widget.qualification.status == ApprovalStatus.pending)
                Card(
                  color: AppColors.warningOrangeTransparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppColors.warningOrange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This qualification is currently pending review. Editing will reset its status.',
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Institution Field
              TextFormField(
                controller: _institutionController,
                decoration: InputDecoration(
                  labelText: '${AppStrings.institution} *',
                  hintText: 'e.g., University of Cape Town',
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: Validators.validateInstitution,
              ),

              const SizedBox(height: 16),

              // Qualification Field
              TextFormField(
                controller: _qualificationController,
                decoration: InputDecoration(
                  labelText: '${AppStrings.qualificationName} *',
                  hintText: 'e.g., Bachelor of Science in Computer Science',
                  prefixIcon: const Icon(Icons.workspace_premium_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                maxLines: 2,
                validator: Validators.validateQualification,
              ),

              const SizedBox(height: 16),

              // Completion Date Field
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText:
                        '${AppStrings.completionDate} (${AppStrings.optional})',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _completionDate != null
                        ? DateFormat('MMMM yyyy').format(_completionDate!)
                        : 'Select completion date',
                    style: TextStyle(
                      color: _completionDate != null
                          ? AppColors.darkGrey
                          : AppColors.hintText,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Certificate Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            color: AppColors.deepBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.certificate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Current Certificate
                      if (widget.qualification.certificateUrl != null &&
                          _selectedCertificate == null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.successGreenTransparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.successGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.successGreen,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Certificate attached',
                                  style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: View certificate
                                },
                                child: const Text('View'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // New Selected Certificate
                      if (_selectedCertificate != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: AppColors.deepBlue,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedCertificate!.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.darkGrey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${(_selectedCertificate!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.mediumGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedCertificate = null;
                                  });
                                  Provider.of<QualificationController>(context,
                                          listen: false)
                                      .clearSelectedCertificate();
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.errorRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _selectCertificate,
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                            _selectedCertificate != null ||
                                    widget.qualification.certificateUrl != null
                                ? 'Change Certificate'
                                : 'Upload Certificate',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Update Button
              Consumer<QualificationController>(
                builder: (context, controller, _) {
                  return ElevatedButton(
                    onPressed:
                        controller.isLoading ? null : _updateQualification,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                            ),
                          )
                        : const Text(
                            AppStrings.update,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
