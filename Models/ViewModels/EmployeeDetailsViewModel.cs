// Models/ViewModels/EmployeeDetailsViewModel.cs
namespace SkillsAuditSystem.Models.ViewModels
{
    public class EmployeeDetailsViewModel
    {
        public Employee Employee { get; set; } = new Employee();
        public List<Qualification> Qualifications { get; set; } = new List<Qualification>();
        public List<Training> Trainings { get; set; } = new List<Training>();
        public List<Skill> Skills { get; set; } = new List<Skill>();

        // Statistics
        public int TotalQualifications { get; set; }
        public int ApprovedQualifications { get; set; }
        public int PendingQualifications { get; set; }
        public int CompletedTrainings { get; set; }
        public int InProgressTrainings { get; set; }
        public int TotalSkills { get; set; }
    }
}