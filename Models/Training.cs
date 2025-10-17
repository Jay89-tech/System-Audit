using Google.Cloud.Firestore;

namespace SkillsAuditSystem.Models
{
    [FirestoreData]
    public class Training
    {
        [FirestoreProperty("id")]
        public string Id { get; set; } = string.Empty;

        [FirestoreProperty("employeeId")]
        public string EmployeeId { get; set; } = string.Empty;

        [FirestoreProperty("trainingName")]
        public string TrainingName { get; set; } = string.Empty;

        [FirestoreProperty("description")]
        public string? Description { get; set; }

        [FirestoreProperty("provider")]
        public string? Provider { get; set; }

        [FirestoreProperty("status")]
        public string Status { get; set; } = "not_started"; // "not_started", "in_progress", "completed", "suggested"

        [FirestoreProperty("startDate")]
        public DateTime? StartDate { get; set; }

        [FirestoreProperty("endDate")]
        public DateTime? EndDate { get; set; }

        [FirestoreProperty("completionDate")]
        public DateTime? CompletionDate { get; set; }

        [FirestoreProperty("progress")]
        public int Progress { get; set; } = 0; // 0-100

        [FirestoreProperty("certificateUrl")]
        public string? CertificateUrl { get; set; }

        [FirestoreProperty("suggestedBy")]
        public string? SuggestedBy { get; set; } // Admin ID who suggested

        [FirestoreProperty("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [FirestoreProperty("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}