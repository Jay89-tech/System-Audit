import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/qualification_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../../utils/validators.dart';

class AddQualificationScreen extends StatefulWidget {
  const AddQualificationScreen({super.key});

  @override
  State<AddQualificationScreen> createState() => _AddQualificationScreenState();
}

class _AddQualificationScreenState extends State<AddQualificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _qualificationController = TextEditingController();
  DateTime? _completionDate;
  PlatformFile? _selectedCertificate;

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

  Future<void> _saveQualification() async {
    if (_formKey.currentState!.validate()) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      final qualificationController =
          Provider.of<QualificationController>(context, listen: false);

      final success = await qualificationController.addQualification(
        userId: authController.currentUser!.uid,
        institution: _institutionController.text.trim(),
        qualification: _qualificationController.text.trim(),
        completionDate: _completionDate,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.qualificationAdded),
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
        title: const Text(AppStrings.addQualification),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Information Card
              Card(
                color: AppColors.deepBlueTransparent,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.deepBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add your educational qualifications and certifications. HR will review and approve them.',
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

              // Certificate Upload Section
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
                            '${AppStrings.certificate} (${AppStrings.optional})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload a PDF, JPG, or PNG file (max 10MB)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                            _selectedCertificate == null
                                ? AppStrings.selectFile
                                : 'Change File',
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

              // Save Button
              Consumer<QualificationController>(
                builder: (context, controller, _) {
                  return ElevatedButton(
                    onPressed: controller.isLoading ? null : _saveQualification,
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
                            AppStrings.submit,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Info Text
              Text(
                'Your qualification will be submitted for review. You\'ll be notified once it\'s approved.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
