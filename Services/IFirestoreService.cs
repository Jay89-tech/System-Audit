using SkillsAuditSystem.Models;

namespace SkillsAuditSystem.Services
{
    public interface IFirestoreService
    {
        // Employee Operations
        Task<Employee?> GetEmployeeByIdAsync(string employeeId);
        Task<Employee?> GetEmployeeByUidAsync(string uid);
        Task<List<Employee>> GetAllEmployeesAsync();
        Task<List<Employee>> GetActiveEmployeesAsync();
        Task<bool> CreateEmployeeAsync(Employee employee);
        Task<bool> UpdateEmployeeAsync(Employee employee);
        Task<bool> DeleteEmployeeAsync(string employeeId);
        Task<int> GetTotalEmployeesCountAsync();

        // Qualification Operations
        Task<Qualification?> GetQualificationByIdAsync(string qualificationId);
        Task<List<Qualification>> GetQualificationsByEmployeeIdAsync(string employeeId);
        Task<List<Qualification>> GetPendingQualificationsAsync();
        Task<bool> CreateQualificationAsync(Qualification qualification);
        Task<bool> UpdateQualificationAsync(Qualification qualification);
        Task<bool> DeleteQualificationAsync(string qualificationId);
        Task<bool> ApproveQualificationAsync(string qualificationId, string approvedBy);
        Task<bool> RejectQualificationAsync(string qualificationId, string rejectionReason);

        // Training Operations
        Task<Training?> GetTrainingByIdAsync(string trainingId);
        Task<List<Training>> GetTrainingsByEmployeeIdAsync(string employeeId);
        Task<List<Training>> GetSuggestedTrainingsAsync();
        Task<bool> CreateTrainingAsync(Training training);
        Task<bool> UpdateTrainingAsync(Training training);
        Task<bool> DeleteTrainingAsync(string trainingId);
        Task<List<Training>> GetTrainingsByStatusAsync(string status);

        // Skill Operations
        Task<Skill?> GetSkillByIdAsync(string skillId);
        Task<List<Skill>> GetSkillsByEmployeeIdAsync(string employeeId);
        Task<bool> CreateSkillAsync(Skill skill);
        Task<bool> UpdateSkillAsync(Skill skill);
        Task<bool> DeleteSkillAsync(string skillId);
        Task<Dictionary<string, int>> GetSkillCategoriesDistributionAsync();

        // Dashboard & Analytics
        Task<Dictionary<string, int>> GetEmployeesByProfessionAsync();
        Task<Dictionary<string, int>> GetTrainingStatusDistributionAsync();
        Task<int> GetPendingApprovalsCountAsync();
    }
}