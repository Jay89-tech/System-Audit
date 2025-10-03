import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/training_controller.dart';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final trainingController =
        Provider.of<TrainingController>(context, listen: false);
    await Future.wait([
      trainingController.loadTrainings(),
      trainingController.loadSkills(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training & Skills'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Training', icon: Icon(Icons.trending_up)),
            Tab(text: 'Skills', icon: Icon(Icons.star)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TrainingTab(),
          _SkillsTab(),
        ],
      ),
    );
  }
}

class _TrainingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<TrainingController>(context, listen: false)
            .loadTrainings();
      },
      child: Consumer<TrainingController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.trainings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.trainings.isEmpty) {
            return _buildEmptyTrainingState();
          }

          // Group trainings by status
          final suggested = controller.getSuggestedTrainings();
          final inProgress =
              controller.getTrainingsByStatus(TrainingStatus.inProgress);
          final completed =
              controller.getTrainingsByStatus(TrainingStatus.completed);
          final notStarted = controller
              .getTrainingsByStatus(TrainingStatus.notStarted)
              .where((t) => !t.isSuggested)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Overview Card
                _buildProgressOverviewCard(controller),

                const SizedBox(height: 20),

                // Suggested Trainings
                if (suggested.isNotEmpty) ...[
                  _buildSectionHeader(
                      'Suggested for You', Icons.lightbulb_outline),
                  const SizedBox(height: 12),
                  ...suggested
                      .map((training) => _buildTrainingCard(training, true)),
                  const SizedBox(height: 20),
                ],

                // In Progress
                if (inProgress.isNotEmpty) ...[
                  _buildSectionHeader('In Progress', Icons.play_circle_outline),
                  const SizedBox(height: 12),
                  ...inProgress
                      .map((training) => _buildTrainingCard(training, false)),
                  const SizedBox(height: 20),
                ],

                // Available Trainings
                if (notStarted.isNotEmpty) ...[
                  _buildSectionHeader(
                      'Available Trainings', Icons.school_outlined),
                  const SizedBox(height: 12),
                  ...notStarted
                      .map((training) => _buildTrainingCard(training, false)),
                  const SizedBox(height: 20),
                ],

                // Completed
                if (completed.isNotEmpty) ...[
                  _buildSectionHeader('Completed', Icons.check_circle_outline),
                  const SizedBox(height: 12),
                  ...completed
                      .map((training) => _buildTrainingCard(training, false)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTrainingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_outlined,
              size: 80,
              color: AppColors.softGrey,
            ),
            const SizedBox(height: 24),
            Text(
              'No Trainings Available',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.mediumGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your HR team will assign training programs based on your role and development needs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverviewCard(TrainingController controller) {
    final totalTrainings = controller.trainings.length;
    final completed = controller.getCompletedTrainingCount();
    final averageProgress = controller.getAverageTrainingProgress();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training Progress Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                      'Total', totalTrainings.toString(), Icons.school),
                ),
                Expanded(
                  child: _buildStatItem(
                      'Completed', completed.toString(), Icons.check_circle),
                ),
                Expanded(
                  child: _buildStatItem('Progress',
                      '${averageProgress.toInt()}%', Icons.trending_up),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.deepBlue, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.mediumGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingCard(TrainingModel training, bool isSuggested) {
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
                  child: Text(
                    training.trainingName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
                if (isSuggested)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Suggested',
                      style: TextStyle(
                        color: AppColors.warningOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            if (training.description != null) ...[
              const SizedBox(height: 8),
              Text(
                training.description!,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 14,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: training.progress / 100.0,
                    backgroundColor: AppColors.softGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(training.progress)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${training.progress.toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(training.status),
                if (training.status == TrainingStatus.inProgress ||
                    training.status == TrainingStatus.notStarted)
                  TextButton(
                    onPressed: () => _showUpdateProgressDialog(training),
                    child: Text(
                      training.status == TrainingStatus.notStarted
                          ? 'Start Training'
                          : 'Update Progress',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TrainingStatus status) {
    Color color;
    String text;

    switch (status) {
      case TrainingStatus.completed:
        color = AppColors.successGreen;
        text = 'Completed';
        break;
      case TrainingStatus.inProgress:
        color = AppColors.blueAccent;
        text = 'In Progress';
        break;
      case TrainingStatus.suspended:
        color = AppColors.errorRed;
        text = 'Suspended';
        break;
      case TrainingStatus.notStarted:
      default:
        color = AppColors.mediumGrey;
        text = 'Not Started';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 25) return AppColors.errorRed;
    if (progress < 50) return AppColors.warningOrange;
    if (progress < 75) return AppColors.blueAccent;
    return AppColors.successGreen;
  }

  void _showUpdateProgressDialog(TrainingModel training) {
    showDialog(
      context: Navigator.of(context).context,
      builder: (context) => _ProgressUpdateDialog(training: training),
    );
  }
}

class _SkillsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.skills.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Skills',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddSkillDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Skill'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.skills.isEmpty
                  ? _buildEmptySkillsState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.skills.length,
                      itemBuilder: (context, index) {
                        final skill = controller.skills[index];
                        return _buildSkillCard(skill, context);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptySkillsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 80,
              color: AppColors.softGrey,
            ),
            const SizedBox(height: 24),
            Text(
              'No Skills Added Yet',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.mediumGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add your skills to showcase your expertise and track your professional development.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddSkillDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Skill'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard(SkillModel skill, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.skillName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSkillLevelIndicator(skill.level),
                      const SizedBox(width: 16),
                      Text(
                        '${skill.experience} months experience',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleSkillAction(value, skill, context),
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
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppColors.errorRed),
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
      ),
    );
  }

  Widget _buildSkillLevelIndicator(SkillLevel level) {
    Color color;
    String text;
    int stars;

    switch (level) {
      case SkillLevel.expert:
        color = AppColors.successGreen;
        text = 'Expert';
        stars = 4;
        break;
      case SkillLevel.advanced:
        color = AppColors.blueAccent;
        text = 'Advanced';
        stars = 3;
        break;
      case SkillLevel.intermediate:
        color = AppColors.warningOrange;
        text = 'Intermediate';
        stars = 2;
        break;
      case SkillLevel.beginner:
      default:
        color = AppColors.mediumGrey;
        text = 'Beginner';
        stars = 1;
        break;
    }

    return Row(
      children: [
        ...List.generate(
            4,
            (index) => Icon(
                  index < stars ? Icons.star : Icons.star_outline,
                  color: color,
                  size: 16,
                )),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _handleSkillAction(
      String action, SkillModel skill, BuildContext context) {
    switch (action) {
      case 'edit':
        _showEditSkillDialog(context, skill);
        break;
      case 'delete':
        _showDeleteSkillDialog(context, skill);
        break;
    }
  }

  void _showAddSkillDialog(BuildContext context) {
    _showSkillDialog(context);
  }

  void _showEditSkillDialog(BuildContext context, SkillModel skill) {
    _showSkillDialog(context, skill: skill);
  }

  void _showSkillDialog(BuildContext context, {SkillModel? skill}) {
    showDialog(
      context: context,
      builder: (context) => _SkillFormDialog(
        skill: skill,
        onSave: (skillName, level, experience) async {
          final authController =
              Provider.of<AuthController>(context, listen: false);
          final trainingController =
              Provider.of<TrainingController>(context, listen: false);

          bool success;
          if (skill != null) {
            success = await trainingController.updateSkill(
              skillId: skill.id,
              level: level,
              experience: experience,
            );
          } else {
            success = await trainingController.addSkill(
              userId: authController.currentUser!.uid,
              skillName: skillName,
              level: level,
              experience: experience,
            );
          }

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(skill != null
                    ? 'Skill updated successfully'
                    : 'Skill added successfully'),
                backgroundColor: AppColors.successGreen,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteSkillDialog(BuildContext context, SkillModel skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text('Are you sure you want to delete "${skill.skillName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final trainingController =
                  Provider.of<TrainingController>(context, listen: false);
              final success = await trainingController.deleteSkill(skill.id);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Skill deleted successfully'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Progress Update Dialog
class _ProgressUpdateDialog extends StatefulWidget {
  final TrainingModel training;

  const _ProgressUpdateDialog({required this.training});

  @override
  State<_ProgressUpdateDialog> createState() => _ProgressUpdateDialogState();
}

class _ProgressUpdateDialogState extends State<_ProgressUpdateDialog> {
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.training.progress;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.training.trainingName),
          const SizedBox(height: 20),
          Text('Progress: ${_progress.toInt()}%'),
          Slider(
            value: _progress,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (value) => setState(() => _progress = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final controller =
                Provider.of<TrainingController>(context, listen: false);
            await controller.updateTrainingProgress(
              trainingId: widget.training.id,
              progress: _progress,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

// Skill Form Dialog
class _SkillFormDialog extends StatefulWidget {
  final SkillModel? skill;
  final Function(String skillName, SkillLevel level, int experience) onSave;

  const _SkillFormDialog({this.skill, required this.onSave});

  @override
  State<_SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends State<_SkillFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _skillNameController = TextEditingController();
  SkillLevel _selectedLevel = SkillLevel.beginner;
  int _experience = 0;

  @override
  void initState() {
    super.initState();
    if (widget.skill != null) {
      _skillNameController.text = widget.skill!.skillName;
      _selectedLevel = widget.skill!.level;
      _experience = widget.skill!.experience;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.skill != null ? 'Edit Skill' : 'Add Skill'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.skill ==
                  null) // Only show skill name field for new skills
                TextFormField(
                  controller: _skillNameController,
                  decoration: const InputDecoration(labelText: 'Skill Name'),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Skill name is required' : null,
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SkillLevel>(
                value: _selectedLevel,
                decoration: const InputDecoration(labelText: 'Skill Level'),
                items: SkillLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedLevel = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _experience.toString(),
                decoration:
                    const InputDecoration(labelText: 'Experience (months)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final exp = int.tryParse(value ?? '');
                  if (exp == null || exp < 0) return 'Enter valid experience';
                  return null;
                },
                onChanged: (value) => _experience = int.tryParse(value) ?? 0,
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
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_skillNameController.text.trim(), _selectedLevel,
                  _experience);
              Navigator.pop(context);
            }
          },
          child: Text(widget.skill != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
