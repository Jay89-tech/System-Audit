import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cellController = TextEditingController();
  final _professionController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user =
        Provider.of<AuthController>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _cellController.text = user.cellNumber;
      _professionController.text = user.profession;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cellController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      final profileController =
          Provider.of<ProfileController>(context, listen: false);

      final success = await profileController.updateProfile(
        userId: authController.currentUser!.uid,
        name: _nameController.text.trim(),
        cellNumber: _cellController.text.trim(),
        profession: _professionController.text.trim(),
        currentImageUrl: authController.currentUser?.profileImageUrl,
      );

      if (success && mounted) {
        // Update auth controller with new data
        await authController.updateProfile(
          name: _nameController.text.trim(),
          cellNumber: _cellController.text.trim(),
          profession: _professionController.text.trim(),
        );

        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                profileController.errorMessage ?? 'Failed to update profile'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<ProfileController>(context, listen: false)
                    .takeProfilePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<ProfileController>(context, listen: false)
                    .selectProfileImage();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                _loadUserData(); // Reset form
                Provider.of<ProfileController>(context, listen: false)
                    .clearSelectedImage();
              },
              child: const Text('Cancel'),
            ),
            Consumer<ProfileController>(
              builder: (context, profileController, _) {
                return TextButton(
                  onPressed: profileController.isLoading ? null : _saveProfile,
                  child: profileController.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                );
              },
            ),
          ] else
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileForm(),
            const SizedBox(height: 24),
            _buildAccountInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer2<AuthController, ProfileController>(
      builder: (context, authController, profileController, _) {
        final user = authController.currentUser;
        final selectedImage = profileController.selectedImage;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.softGrey,
                      backgroundImage: _getProfileImage(user, selectedImage),
                      child: _getProfileImage(user, selectedImage) == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.mediumGrey,
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.deepBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User Name',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  user?.profession ?? 'Profession',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ImageProvider? _getProfileImage(UserModel? user, XFile? selectedImage) {
    if (selectedImage != null) {
      return FileImage(File(selectedImage.path));
    } else if (user?.profileImageUrl != null &&
        user!.profileImageUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(user.profileImageUrl!);
    }
    return null;
  }

  Widget _buildProfileForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Cell Number Field
              TextFormField(
                controller: _cellController,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Cell Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cell number is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Profession Field
              TextFormField(
                controller: _professionController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Profession',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Profession is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  'Email Address',
                  user?.email ?? 'Not available',
                  Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Account Created',
                  user?.createdAt != null
                      ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                      : 'Not available',
                  Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Last Updated',
                  user?.updatedAt != null
                      ? '${user!.updatedAt.day}/${user.updatedAt.month}/${user.updatedAt.year}'
                      : 'Not available',
                  Icons.update_outlined,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showSignOutDialog(),
                    icon: const Icon(Icons.logout, color: AppColors.errorRed),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.errorRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.mediumGrey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content:
            const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthController>(context, listen: false).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
