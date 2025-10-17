// Models/ViewModels/DashboardViewModel.cs
namespace SkillsAuditSystem.Models.ViewModels
{
    public class DashboardViewModel
    {
        public int TotalEmployees { get; set; }
        public int ActiveEmployees { get; set; }
        public int TotalQualifications { get; set; }
        public int PendingApprovals { get; set; }
        public int CompletedTrainings { get; set; }
        public int InProgressTrainings { get; set; }

        public List<Employee> RecentEmployees { get; set; } = new List<Employee>();
        public List<Qualification> PendingQualifications { get; set; } = new List<Qualification>();
        public List<Training> SuggestedTrainings { get; set; } = new List<Training>();

        // Chart Data
        public Dictionary<string, int> EmployeesByProfession { get; set; } = new Dictionary<string, int>();
        public Dictionary<string, int> TrainingStatusDistribution { get; set; } = new Dictionary<string, int>();
        public Dictionary<string, int> SkillCategories { get; set; } = new Dictionary<string, int>();
    }
}
