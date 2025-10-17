using Google.Cloud.Firestore;

namespace SkillsAuditSystem.Models
{
    [FirestoreData]
    public class Qualification
    {
        [FirestoreProperty("id")]
        public string Id { get; set; } = string.Empty;

        [FirestoreProperty("employeeId")]
        public string EmployeeId { get; set; } = string.Empty;

        [FirestoreProperty("institution")]
        public string Institution { get; set; } = string.Empty;

        [FirestoreProperty("qualificationName")]
        public string QualificationName { get; set; } = string.Empty;

        [FirestoreProperty("yearObtained")]
        public int? YearObtained { get; set; }

        [FirestoreProperty("certificateUrl")]
        public string? CertificateUrl { get; set; }

        [FirestoreProperty("status")]
        public string Status { get; set; } = "pending"; // "pending", "approved", "rejected"

        [FirestoreProperty("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [FirestoreProperty("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [FirestoreProperty("approvedBy")]
        public string? ApprovedBy { get; set; }

        [FirestoreProperty("approvedAt")]
        public DateTime? ApprovedAt { get; set; }

        [FirestoreProperty("rejectionReason")]
        public string? RejectionReason { get; set; }
    }
}