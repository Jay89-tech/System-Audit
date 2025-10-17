using Google.Cloud.Firestore;
using SkillsAuditSystem.Models;
using SkillsAuditSystem.Models.ViewModels;
using SkillsAuditSystem.Services;

namespace SkillsAuditSystem.Services
{
    public class FirestoreService : IFirestoreService
    {
        private readonly FirestoreDb _firestoreDb;
        private readonly ILogger<FirestoreService> _logger;

        private const string EmployeesCollection = "employees";
        private const string QualificationsCollection = "qualifications";
        private const string TrainingsCollection = "trainings";
        private const string SkillsCollection = "skills";

        public FirestoreService(FirestoreDb firestoreDb, ILogger<FirestoreService> logger)
        {
            _firestoreDb = firestoreDb;
            _logger = logger;
        }

        #region Employee Operations

        public async Task<Employee?> GetEmployeeByIdAsync(string employeeId)
        {
            try
            {
                if (string.IsNullOrEmpty(employeeId))
                {
                    _logger.LogWarning("GetEmployeeByIdAsync called with null or empty employeeId");
                    return null;
                }

                var docRef = _firestoreDb.Collection(EmployeesCollection).Document(employeeId);
                var snapshot = await docRef.GetSnapshotAsync();

                if (snapshot.Exists)
                {
                    return snapshot.ConvertTo<Employee>();
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting employee by ID {employeeId}: {ex.Message}");
                return null;
            }
        }

        public async Task<Employee?> GetEmployeeByUidAsync(string uid)
        {
            try
            {
                if (string.IsNullOrEmpty(uid))
                {
                    _logger.LogWarning("GetEmployeeByUidAsync called with null or empty uid");
                    return null;
                }

                var query = _firestoreDb.Collection(EmployeesCollection).WhereEqualTo("uid", uid).Limit(1);
                var snapshot = await query.GetSnapshotAsync();

                if (snapshot.Documents.Count > 0)
                {
                    var employee = snapshot.Documents[0].ConvertTo<Employee>();
                    employee.Id = snapshot.Documents[0].Id; // Ensure ID is set from document ID
                    return employee;
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting employee by UID {uid}: {ex.Message}");
                return null;
            }
        }

        public async Task<List<Employee>> GetAllEmployeesAsync()
        {
            try
            {
                var snapshot = await _firestoreDb.Collection(EmployeesCollection).GetSnapshotAsync();
                var employees = new List<Employee>();

                foreach (var document in snapshot.Documents)
                {
                    var employee = document.ConvertTo<Employee>();
                    employee.Id = document.Id; // Ensure ID is set from document ID
                    employees.Add(employee);
                }

                return employees;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting all employees: {ex.Message}");
                return new List<Employee>();
            }
        }

        public async Task<List<Employee>> GetActiveEmployeesAsync()
        {
            try
            {
                var query = _firestoreDb.Collection(EmployeesCollection).WhereEqualTo("isActive", true);
                var snapshot = await query.GetSnapshotAsync();
                var employees = new List<Employee>();

                foreach (var document in snapshot.Documents)
                {
                    var employee = document.ConvertTo<Employee>();
                    employee.Id = document.Id; // Ensure ID is set from document ID
                    employees.Add(employee);
                }

                return employees;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting active employees: {ex.Message}");
                return new List<Employee>();
            }
        }

        public async Task<bool> CreateEmployeeAsync(Employee employee)
        {
            try
            {
                employee.Id = Guid.NewGuid().ToString();
                employee.CreatedAt = DateTime.UtcNow;
                employee.UpdatedAt = DateTime.UtcNow;

                var docRef = _firestoreDb.Collection(EmployeesCollection).Document(employee.Id);
                await docRef.SetAsync(employee);

                _logger.LogInformation($"Employee created: {employee.Id}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating employee: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateEmployeeAsync(Employee employee)
        {
            try
            {
                employee.UpdatedAt = DateTime.UtcNow;
                var docRef = _firestoreDb.Collection(EmployeesCollection).Document(employee.Id);
                await docRef.SetAsync(employee, SetOptions.MergeAll);

                _logger.LogInformation($"Employee updated: {employee.Id}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating employee: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> DeleteEmployeeAsync(string employeeId)
        {
            try
            {
                var docRef = _firestoreDb.Collection(EmployeesCollection).Document(employeeId);
                await docRef.DeleteAsync();

                _logger.LogInformation($"Employee deleted: {employeeId}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting employee: {ex.Message}");
                return false;
            }
        }

        public async Task<int> GetTotalEmployeesCountAsync()
        {
            try
            {
                var snapshot = await _firestoreDb.Collection(EmployeesCollection).GetSnapshotAsync();
                return snapshot.Count;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting employees count: {ex.Message}");
                return 0;
            }
        }

        #endregion

        #region Qualification Operations

        public async Task<Qualification?> GetQualificationByIdAsync(string qualificationId)
        {
            try
            {
                var docRef = _firestoreDb.Collection(QualificationsCollection).Document(qualificationId);
                var snapshot = await docRef.GetSnapshotAsync();

                if (snapshot.Exists)
                {
                    return snapshot.ConvertTo<Qualification>();
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting qualification: {ex.Message}");
                return null;
            }
        }

        public async Task<List<Qualification>> GetQualificationsByEmployeeIdAsync(string employeeId)
        {
            try
            {
                var query = _firestoreDb.Collection(QualificationsCollection).WhereEqualTo("employeeId", employeeId);
                var snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Select(d => d.ConvertTo<Qualification>()).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting qualifications by employee: {ex.Message}");
                return new List<Qualification>();
            }
        }

        public async Task<List<Qualification>> GetPendingQualificationsAsync()
        {
            try
            {
                var query = _firestoreDb.Collection(QualificationsCollection).WhereEqualTo("status", "pending");
                var snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Select(d => d.ConvertTo<Qualification>()).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting pending qualifications: {ex.Message}");
                return new List<Qualification>();
            }
        }

        public async Task<bool> CreateQualificationAsync(Qualification qualification)
        {
            try
            {
                qualification.Id = Guid.NewGuid().ToString();
                qualification.CreatedAt = DateTime.UtcNow;
                qualification.UpdatedAt = DateTime.UtcNow;

                var docRef = _firestoreDb.Collection(QualificationsCollection).Document(qualification.Id);
                await docRef.SetAsync(qualification);

                _logger.LogInformation($"Qualification created: {qualification.Id}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating qualification: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateQualificationAsync(Qualification qualification)
        {
            try
            {
                qualification.UpdatedAt = DateTime.UtcNow;
                var docRef = _firestoreDb.Collection(QualificationsCollection).Document(qualification.Id);
                await docRef.SetAsync(qualification, SetOptions.MergeAll);

                _logger.LogInformation($"Qualification updated: {qualification.Id}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating qualification: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> DeleteQualificationAsync(string qualificationId)
        {
            try
            {
                var docRef = _firestoreDb.Collection(QualificationsCollection).Document(qualificationId);
                await docRef.DeleteAsync();

                _logger.LogInformation($"Qualification deleted: {qualificationId}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting qualification: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> ApproveQualificationAsync(string qualificationId, string approvedBy)
        {
            try
            {
                var docRef = _firestoreDb.Collection(QualificationsCollection).Document(qualificationId);
                var updates = new Dictionary<string, object>
                {
                    { "status", "approved" },
                    { "approvedBy", approvedBy },
                    { "approvedAt", DateTime.UtcNow },
                    { "updatedAt", DateTime.UtcNow }
                };

                await docRef.UpdateAsync(updates);
                _logger.LogInformation($"Qualification approved: {qualificationId}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error approving qualification: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> RejectQualificationAsync(string qualificationId, string rejectionReason)
        {
            try
            {
                var docRef = _firestoreDb.Collection(QualificationsCollection).Document(qualificationId);
                var updates = new Dictionary<string, object>
                {
                    { "status", "rejected" },
                    { "rejectionReason", rejectionReason },
                    { "updatedAt", DateTime.UtcNow }
                };

                await docRef.UpdateAsync(updates);
                _logger.LogInformation($"Qualification rejected: {qualificationId}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error rejecting qualification: {ex.Message}");
                return false;
            }
        }

        #endregion

        #region Training Operations

        public async Task<Training?> GetTrainingByIdAsync(string trainingId)
        {
            try
            {
                var docRef = _firestoreDb.Collection(TrainingsCollection).Document(trainingId);
                var snapshot = await docRef.GetSnapshotAsync();

                if (snapshot.Exists)
                {
                    return snapshot.ConvertTo<Training>();
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting training: {ex.Message}");
                return null;
            }
        }

        public async Task<List<Training>> GetTrainingsByEmployeeIdAsync(string employeeId)
        {
            try
            {
                var query = _firestoreDb.Collection(TrainingsCollection).WhereEqualTo("employeeId", employeeId);
                var snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Select(d => d.ConvertTo<Training>()).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting trainings by employee: {ex.Message}");
                return new List<Training>();
            }
        }

        public async Task<List<Training>> GetSuggestedTrainingsAsync()
        {
            try
            {
                var query = _firestoreDb.Collection(TrainingsCollection).WhereEqualTo("status", "suggested");
                var snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Select(d => d.ConvertTo<Training>()).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting suggested trainings: {ex.Message}");
                return new List<Training>();
            }
        }

        public async Task<bool> CreateTrainingAsync(Training training)
        {
            try
            {
                training.Id = Guid.NewGuid().ToString();
                training.CreatedAt = DateTime.UtcNow;
                training.UpdatedAt = DateTime.UtcNow;

                var docRef = _firestoreDb.Collection(TrainingsCollection).Document(training.Id);
                await docRef.SetAsync(training);

                _logger.LogInformation($"Training created: {training.Id}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating training: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateTrainingAsync(Training training)
        {
            try
            {
                training.UpdatedAt = DateTime.UtcNow;
                var docRef = _firestoreDb.Collection(TrainingsCollection).Document(training.Id);
                await docRef.SetAsync(training, SetOptions.MergeAll);

                _logger.LogInformation($"Training updated: {training.Id}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating training: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> DeleteTrainingAsync(string trainingId)
        {
            try
            {
                var docRef = _firestoreDb.Collection(TrainingsCollection).Document(trainingId);
                await docRef.DeleteAsync();

                _logger.LogInformation($"Training deleted: {trainingId}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting training: {ex.Message}");
                return false;
            }
        }

        public async Task<List<Training>> GetTrainingsByStatusAsync(string status)
        {
            try
            {
                var query = _firestoreDb.Collection(TrainingsCollection).WhereEqualTo("status", status);
                var snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Select(d => d.ConvertTo<Training>()).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting trainings by status: {ex.Message}");
                return new List<Training>();
            }
        }

        #endregion

        #region Skill Operations

        public async Task<Skill?> GetSkillByIdAsync(string skillId)
        {
            try
            {
                var docRef = _firestoreDb.Collection(SkillsCollection).Document(skillId);
                var snapshot = await docRef.GetSnapshotAsync();

                if (snapshot.Exists)
                {
                    return snapshot.ConvertTo<Skill>();
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting skill: {ex.Message}");
                return null;
            }
        }

        public async Task<List<Skill>> GetSkillsByEmployeeIdAsync(string employeeId)
        {
            try
            {
                var query = _firestoreDb.Collection(SkillsCollection).WhereEqualTo("employeeId", employeeId);
                var snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Select(d => d.ConvertTo<Skill>()).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting skills by employee: {ex.Message}");
                return new List<Skill>();
            }
        }

        public async Task<bool> CreateSkillAsync(Skill skill)
        {
            try
            {
                skill.Id = Guid.NewGuid().ToString();
                skill.CreatedAt = DateTime.UtcNow;
                skill.UpdatedAt = DateTime.UtcNow;

                var docRef = _firestoreDb.Collection(SkillsCollection).Document(skill.Id);
                await docRef.SetAsync(skill);

                _logger.LogInformation($"Skill created: {skill.Id}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating skill: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateSkillAsync(Skill skill)
        {
            try
            {
                skill.UpdatedAt = DateTime.UtcNow;
                var docRef = _firestoreDb.Collection(SkillsCollection).Document(skill.Id);
                await docRef.SetAsync(skill, SetOptions.MergeAll);

                _logger.LogInformation($"Skill updated: {skill.Id}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating skill: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> DeleteSkillAsync(string skillId)
        {
            try
            {
                var docRef = _firestoreDb.Collection(SkillsCollection).Document(skillId);
                await docRef.DeleteAsync();

                _logger.LogInformation($"Skill deleted: {skillId}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting skill: {ex.Message}");
                return false;
            }
        }

        public async Task<Dictionary<string, int>> GetSkillCategoriesDistributionAsync()
        {
            try
            {
                var snapshot = await _firestoreDb.Collection(SkillsCollection).GetSnapshotAsync();
                var skills = snapshot.Documents.Select(d => d.ConvertTo<Skill>()).ToList();

                return skills
                    .GroupBy(s => s.Category)
                    .ToDictionary(g => g.Key, g => g.Count());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting skill categories distribution: {ex.Message}");
                return new Dictionary<string, int>();
            }
        }

        #endregion

        #region Dashboard & Analytics

        public async Task<Dictionary<string, int>> GetEmployeesByProfessionAsync()
        {
            try
            {
                var snapshot = await _firestoreDb.Collection(EmployeesCollection).GetSnapshotAsync();
                var employees = snapshot.Documents.Select(d => d.ConvertTo<Employee>()).ToList();

                return employees
                    .GroupBy(e => e.Profession)
                    .ToDictionary(g => g.Key, g => g.Count());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting employees by profession: {ex.Message}");
                return new Dictionary<string, int>();
            }
        }

        public async Task<Dictionary<string, int>> GetTrainingStatusDistributionAsync()
        {
            try
            {
                var snapshot = await _firestoreDb.Collection(TrainingsCollection).GetSnapshotAsync();
                var trainings = snapshot.Documents.Select(d => d.ConvertTo<Training>()).ToList();

                return trainings
                    .GroupBy(t => t.Status)
                    .ToDictionary(g => g.Key, g => g.Count());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting training status distribution: {ex.Message}");
                return new Dictionary<string, int>();
            }
        }

        public async Task<int> GetPendingApprovalsCountAsync()
        {
            try
            {
                var query = _firestoreDb.Collection(QualificationsCollection).WhereEqualTo("status", "pending");
                var snapshot = await query.GetSnapshotAsync();
                return snapshot.Count;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting pending approvals count: {ex.Message}");
                return 0;
            }
        }

        #endregion
    }
}