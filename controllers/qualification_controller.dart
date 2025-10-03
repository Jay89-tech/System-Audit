import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/user_model.dart';

class QualificationController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<QualificationModel> _qualifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  PlatformFile? _selectedCertificate;

  // Getters
  List<QualificationModel> get qualifications => _qualifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PlatformFile? get selectedCertificate => _selectedCertificate;

  // Load qualifications for current user
  Future<void> loadQualifications(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadUserQualifications(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load qualifications';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserQualifications(String userId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('qualifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    _qualifications = snapshot.docs
        .map((doc) => QualificationModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  // Add new qualification
  Future<bool> addQualification({
    required String userId,
    required String institution,
    required String qualification,
    DateTime? completionDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? certificateUrl;

      // Upload certificate if selected
      if (_selectedCertificate != null) {
        certificateUrl = await _uploadCertificate(userId, _selectedCertificate!);
      }

      // Create qualification document
      final qualificationData = QualificationModel(
        id: '', // Will be set by Firestore
        userId: userId,
        institution: institution,
        qualification: qualification,
        completionDate: completionDate,
        certificateUrl: certificateUrl,
        status: ApprovalStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final DocumentReference docRef = await _firestore
          .collection('qualifications')
          .add(qualificationData.toFirestore());

      // Add to local list
      final newQualification = QualificationModel(
        id: docRef.id,
        userId: userId,
        institution: institution,
        qualification: qualification,
        completionDate: completionDate,
        certificateUrl: certificateUrl,
        status: ApprovalStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _qualifications.insert(0, newQualification);
      _selectedCertificate = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add qualification: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update existing qualification
  Future<bool> updateQualification({
    required String qualificationId,
    required String institution,
    required String qualification,
    DateTime? completionDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? certificateUrl;

      // Find existing qualification
      final existingIndex = _qualifications
          .indexWhere((q) => q.id == qualificationId);
      
      if (existingIndex == -1) {
        throw Exception('Qualification not found');
      }

      final existing = _qualifications[existingIndex];

      // Upload new certificate if selected
      if (_selectedCertificate != null) {
        certificateUrl = await _uploadCertificate(existing.userId, _selectedCertificate!);
        
        // Delete old certificate if exists
        if (existing.certificateUrl != null) {
          await _deleteCertificate(existing.certificateUrl!);
        }
      } else {
        certificateUrl = existing.certificateUrl;
      }

      // Update Firestore document
      await _firestore.collection('qualifications').doc(qualificationId).update({
        'institution': institution,
        'qualification': qualification,
        'completionDate': completionDate?.millisecondsSinceEpoch,
        'certificateUrl': certificateUrl,
        'status': ApprovalStatus.pending.toString(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update local list
      _qualifications[existingIndex] = QualificationModel(
        id: existing.id,
        userId: existing.userId,
        institution: institution,
        qualification: qualification,
        completionDate: completionDate,
        certificateUrl: certificateUrl,
        status: ApprovalStatus.pending,
        rejectionReason: null,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      _selectedCertificate = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update qualification: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete qualification
  Future<bool> deleteQualification(String qualificationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Find qualification to delete
      final qualification = _qualifications
          .firstWhere((q) => q.id == qualificationId);

      // Delete certificate if exists
      if (qualification.certificateUrl != null) {
        await _deleteCertificate(qualification.certificateUrl!);
      }

      // Delete from Firestore
      await _firestore.collection('qualifications').doc(qualificationId).delete();

      // Remove from local list
      _qualifications.removeWhere((q) => q.id == qualificationId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete qualification: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Select certificate file
  Future<void> selectCertificate() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        _selectedCertificate = result.files.first;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to select certificate';
      notifyListeners();
    }
  }

  // Clear selected certificate
  void clearSelectedCertificate() {
    _selectedCertificate = null;
    notifyListeners();
  }

  // Upload certificate to Firebase Storage
  Future<String> _uploadCertificate(String userId, PlatformFile file) async {
    try {
      final String fileName = 'certificate_${userId}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final Reference ref = _storage.ref().child('certificates').child(fileName);
      
      final File fileToUpload = File(file.path!);
      final UploadTask uploadTask = ref.putFile(fileToUpload);
      final TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload certificate: ${e.toString()}');
    }
  }

  // Delete certificate from Firebase Storage
  Future<void> _deleteCertificate(String certificateUrl) async {
    try {
      final Reference ref = _storage.refFromURL(certificateUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Failed to delete certificate: $e');
    }
  }

  // Get qualifications by status
  List<QualificationModel> getQualificationsByStatus(ApprovalStatus status) {
    return _qualifications.where((q) => q.status == status).toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}