using SkillsAuditSystem.Models;

namespace SkillsAuditSystem.Services
{
    public interface IReportService
    {
        /// <summary>
        /// Generate PDF report for all employees
        /// </summary>
        Task<byte[]> GenerateEmployeesPdfReportAsync(List<Employee> employees);

        /// <summary>
        /// Generate Excel report for all employees
        /// </summary>
        Task<byte[]> GenerateEmployeesExcelReportAsync(List<Employee> employees);

        /// <summary>
        /// Generate detailed employee report with qualifications, skills, and trainings
        /// </summary>
        Task<byte[]> GenerateDetailedEmployeeReportAsync(Employee employee, List<Qualification> qualifications, List<Skill> skills, List<Training> trainings);

        /// <summary>
        /// Generate skills audit summary report
        /// </summary>
        Task<byte[]> GenerateSkillsAuditSummaryAsync(Dictionary<string, int> skillsDistribution, Dictionary<string, int> professionDistribution);

        /// <summary>
        /// Generate training progress report
        /// </summary>
        Task<byte[]> GenerateTrainingProgressReportAsync(List<Training> trainings);
    }
}