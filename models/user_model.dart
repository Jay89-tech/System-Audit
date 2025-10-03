class UserModel {
  final String uid;
  final String email;
  final String name;
  final String cellNumber;
  final String profession;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final UserRole role;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.cellNumber,
    required this.profession,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.role = UserRole.employee,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      cellNumber: data['cellNumber'] ?? '',
      profession: data['profession'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
      isActive: data['isActive'] ?? true,
      role: UserRole.values.firstWhere(
        (role) => role.toString() == data['role'],
        orElse: () => UserRole.employee,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'cellNumber': cellNumber,
      'profession': profession,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'role': role.toString(),
    };
  }

  UserModel copyWith({
    String? name,
    String? cellNumber,
    String? profession,
    String? profileImageUrl,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      cellNumber: cellNumber ?? this.cellNumber,
      profession: profession ?? this.profession,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      role: role,
    );
  }
}

enum UserRole {
  employee,
  admin,
  hr,
}

class QualificationModel {
  final String id;
  final String userId;
  final String institution;
  final String qualification;
  final DateTime? completionDate;
  final String? certificateUrl;
  final ApprovalStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  QualificationModel({
    required this.id,
    required this.userId,
    required this.institution,
    required this.qualification,
    this.completionDate,
    this.certificateUrl,
    this.status = ApprovalStatus.pending,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QualificationModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return QualificationModel(
      id: id,
      userId: data['userId'] ?? '',
      institution: data['institution'] ?? '',
      qualification: data['qualification'] ?? '',
      completionDate: data['completionDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['completionDate'])
          : null,
      certificateUrl: data['certificateUrl'],
      status: ApprovalStatus.values.firstWhere(
        (status) => status.toString() == data['status'],
        orElse: () => ApprovalStatus.pending,
      ),
      rejectionReason: data['rejectionReason'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'institution': institution,
      'qualification': qualification,
      'completionDate': completionDate?.millisecondsSinceEpoch,
      'certificateUrl': certificateUrl,
      'status': status.toString(),
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

class TrainingModel {
  final String id;
  final String userId;
  final String trainingName;
  final String? description;
  final TrainingStatus status;
  final double progress;
  final DateTime? startDate;
  final DateTime? completionDate;
  final String? certificateUrl;
  final bool isSuggested;
  final String? suggestedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrainingModel({
    required this.id,
    required this.userId,
    required this.trainingName,
    this.description,
    this.status = TrainingStatus.notStarted,
    this.progress = 0.0,
    this.startDate,
    this.completionDate,
    this.certificateUrl,
    this.isSuggested = false,
    this.suggestedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TrainingModel(
      id: id,
      userId: data['userId'] ?? '',
      trainingName: data['trainingName'] ?? '',
      description: data['description'],
      status: TrainingStatus.values.firstWhere(
        (status) => status.toString() == data['status'],
        orElse: () => TrainingStatus.notStarted,
      ),
      progress: (data['progress'] ?? 0.0).toDouble(),
      startDate: data['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['startDate'])
          : null,
      completionDate: data['completionDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['completionDate'])
          : null,
      certificateUrl: data['certificateUrl'],
      isSuggested: data['isSuggested'] ?? false,
      suggestedBy: data['suggestedBy'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'trainingName': trainingName,
      'description': description,
      'status': status.toString(),
      'progress': progress,
      'startDate': startDate?.millisecondsSinceEpoch,
      'completionDate': completionDate?.millisecondsSinceEpoch,
      'certificateUrl': certificateUrl,
      'isSuggested': isSuggested,
      'suggestedBy': suggestedBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

class SkillModel {
  final String id;
  final String userId;
  final String skillName;
  final SkillLevel level;
  final int experience; // in months
  final DateTime lastUpdated;

  SkillModel({
    required this.id,
    required this.userId,
    required this.skillName,
    required this.level,
    required this.experience,
    required this.lastUpdated,
  });

  factory SkillModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SkillModel(
      id: id,
      userId: data['userId'] ?? '',
      skillName: data['skillName'] ?? '',
      level: SkillLevel.values.firstWhere(
        (level) => level.toString() == data['level'],
        orElse: () => SkillLevel.beginner,
      ),
      experience: data['experience'] ?? 0,
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'skillName': skillName,
      'level': level.toString(),
      'experience': experience,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

enum TrainingStatus {
  notStarted,
  inProgress,
  completed,
  suspended,
}

enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}
