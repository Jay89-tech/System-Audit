import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  // Initialize authentication listener
  AuthController() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to check authentication status';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        await _loadUserData(result.user!.uid);
        await _updateFCMToken();
        return true;
      }

      _errorMessage = 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Clear FCM token
      if (_currentUser != null) {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'fcmToken': FieldValue.delete(),
          'lastSignOut': DateTime.now().millisecondsSinceEpoch,
        });
      }

      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out';
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        _currentUser = UserModel.fromFirestore(
          userDoc.data() as Map<String, dynamic>,
          uid,
        );
      } else {
        _errorMessage = 'User data not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String cellNumber,
    required String profession,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        cellNumber: cellNumber,
        profession: profession,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updatedUser.toFirestore());

      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateFCMToken() async {
    if (_currentUser == null) return;

    try {
      final String? fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'fcmToken': fcmToken,
          'lastSignIn': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      // FCM token update is not critical, so we don't show error to user
      debugPrint('Failed to update FCM token: $e');
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'invalid-email':
        return 'Invalid email address';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
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
