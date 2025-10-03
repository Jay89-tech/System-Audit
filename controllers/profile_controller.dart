import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  String? _errorMessage;
  XFile? _selectedImage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  XFile? get selectedImage => _selectedImage;

  Future<bool> updateProfile({
    required String userId,
    required String name,
    required String cellNumber,
    required String profession,
    String? currentImageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? profileImageUrl = currentImageUrl;

      // Upload new profile image if selected
      if (_selectedImage != null) {
        profileImageUrl =
            await _uploadProfileImage(userId, File(_selectedImage!.path));
      }

      // Update user document
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'cellNumber': cellNumber,
        'profession': profession,
        'profileImageUrl': profileImageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      _selectedImage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> selectProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to select image';
      notifyListeners();
    }
  }

  Future<void> takeProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to take photo';
      notifyListeners();
    }
  }

  Future<String?> _uploadProfileImage(String userId, File imageFile) async {
    try {
      final String fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref =
          _storage.ref().child('profile_images').child(fileName);

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
