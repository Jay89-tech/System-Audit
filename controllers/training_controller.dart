import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class TrainingController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TrainingModel> _trainings = [];
  List<SkillModel> _skills = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<TrainingModel> get trainings => _trainings;
  List<SkillModel> get skills => _skills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load trainings for current user
  Future<void> loadTrainings(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadUserTrainings(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load trainings';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserTrainings(String userId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('trainings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    _trainings = snapshot.docs
        .map(
          (doc) => TrainingModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  // Load skills for current user
  Future<void> loadSkills(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadUserSkills(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load skills';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserSkills(String userId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('skills')
        .where('userId', isEqualTo: userId)
        .orderBy('lastUpdated', descending: true)
        .get();

    _skills = snapshot.docs
        .map(
          (doc) => SkillModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  // Update training progress
  Future<bool> updateTrainingProgress({
    required String trainingId,
    required double progress,
    TrainingStatus? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Find training in local list
      final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
      if (trainingIndex == -1) {
        throw Exception('Training not found');
      }

      final training = _trainings[trainingIndex];

      // Determine status based on progress if not provided
      TrainingStatus newStatus = status ?? training.status;
      DateTime? completionDate = training.completionDate;
      DateTime? startDate = training.startDate;

      if (progress > 0 && training.status == TrainingStatus.notStarted) {
        newStatus = TrainingStatus.inProgress;
        startDate = DateTime.now();
      }

      if (progress >= 100.0) {
        newStatus = TrainingStatus.completed;
        completionDate = DateTime.now();
      }

      // Update Firestore
      await _firestore.collection('trainings').doc(trainingId).update({
        'progress': progress,
        'status': newStatus.toString(),
        'startDate': startDate?.millisecondsSinceEpoch,
        'completionDate': completionDate?.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update local list
      _trainings[trainingIndex] = TrainingModel(
        id: training.id,
        userId: training.userId,
        trainingName: training.trainingName,
        description: training.description,
        status: newStatus,
        progress: progress,
        startDate: startDate,
        completionDate: completionDate,
        certificateUrl: training.certificateUrl,
        isSuggested: training.isSuggested,
        suggestedBy: training.suggestedBy,
        createdAt: training.createdAt,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update training progress: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add new skill
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
        _errorMessage = 'Skill already exists';
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

  // Update existing skill
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

  // Delete skill
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

  // Get trainings by status
  List<TrainingModel> getTrainingsByStatus(TrainingStatus status) {
    return _trainings.where((t) => t.status == status).toList();
  }

  // Get suggested trainings
  List<TrainingModel> getSuggestedTrainings() {
    return _trainings.where((t) => t.isSuggested).toList();
  }

  // Get skills by level
  List<SkillModel> getSkillsByLevel(SkillLevel level) {
    return _skills.where((s) => s.level == level).toList();
  }

  // Calculate average training progress
  double getAverageTrainingProgress() {
    if (_trainings.isEmpty) return 0.0;

    final totalProgress = _trainings.fold<double>(
      0.0,
      (sum, training) => sum + training.progress,
    );

    return totalProgress / _trainings.length;
  }

  // Get completed training count
  int getCompletedTrainingCount() {
    return _trainings.where((t) => t.status == TrainingStatus.completed).length;
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
