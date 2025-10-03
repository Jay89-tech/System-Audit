import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class SkillsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<SkillModel> _skills = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<SkillModel> get skills => _skills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSkills(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('skills')
          .where('userId', isEqualTo: userId)
          .orderBy('lastUpdated', descending: true)
          .get();

      _skills = snapshot.docs
          .map((doc) => SkillModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load skills: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSkill({
    required String userId,
    required String skillName,
    required SkillLevel level,
    required int experience,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if skill already exists
      final existingSkill = _skills.firstWhere(
        (s) => s.skillName.toLowerCase() == skillName.toLowerCase(),
        orElse: () => SkillModel(
          id: '',
          userId: '',
          skillName: '',
          level: SkillLevel.beginner,
          experience: 0,
          lastUpdated: DateTime.now(),
        ),
      );

      if (existingSkill.id.isNotEmpty) {
        _errorMessage = 'Skill already exists. Update it instead.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new skill
      final skillData = SkillModel(
        id: '', // Will be set by Firestore
        userId: userId,
        skillName: skillName,
        level: level,
        experience: experience,
        lastUpdated: DateTime.now(),
      );

      final DocumentReference docRef = await _firestore
          .collection('skills')
          .add(skillData.toFirestore());

      // Add to local list
      final newSkill = SkillModel(
        id: docRef.id,
        userId: userId,
        skillName: skillName,
        level: level,
        experience: experience,
        lastUpdated: DateTime.now(),
      );

      _skills.insert(0, newSkill);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add skill: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSkill({
    required String skillId,
    SkillLevel? level,
    int? experience,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final skillIndex = _skills.indexWhere((s) => s.id == skillId);
      if (skillIndex == -1) {
        throw Exception('Skill not found');
      }

      final skill = _skills[skillIndex];
      final updates = <String, dynamic>{
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      if (level != null) {
        updates['level'] = level.toString();
      }
      if (experience != null) {
        updates['experience'] = experience;
      }

      await _firestore.collection('skills').doc(skillId).update(updates);

      // Update local list
      _skills[skillIndex] = SkillModel(
        id: skill.id,
        userId: skill.userId,
        skillName: skill.skillName,
        level: level ?? skill.level,
        experience: experience ?? skill.experience,
        lastUpdated: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update skill: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSkill(String skillId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('skills').doc(skillId).delete();
      _skills.removeWhere((s) => s.id == skillId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete skill: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<SkillModel> getSkillsByLevel(SkillLevel level) {
    return _skills.where((s) => s.level == level).toList();
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