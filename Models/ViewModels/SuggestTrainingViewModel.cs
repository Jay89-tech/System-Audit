// Models/ViewModels/SuggestTrainingViewModel.cs
using System.ComponentModel.DataAnnotations;

namespace SkillsAuditSystem.Models.ViewModels
{
    public class SuggestTrainingViewModel
    {
        [Required]
        public string EmployeeId { get; set; } = string.Empty;

        [Required(ErrorMessage = "Training name is required")]
        public string TrainingName { get; set; } = string.Empty;

        public string? Description { get; set; }

        public string? Provider { get; set; }

        public DateTime? StartDate { get; set; }

        public DateTime? EndDate { get; set; }
    }
}