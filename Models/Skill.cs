using Google.Cloud.Firestore;

namespace SkillsAuditSystem.Models
{
    [FirestoreData]
    public class Skill
    {
        [FirestoreProperty("id")]
        public string Id { get; set; } = string.Empty;

        [FirestoreProperty("employeeId")]
        public string EmployeeId { get; set; } = string.Empty;

        [FirestoreProperty("skillName")]
        public string SkillName { get; set; } = string.Empty;

        [FirestoreProperty("category")]
        public string Category { get; set; } = string.Empty; // e.g., "Technical", "Soft Skills", "Leadership"

        [FirestoreProperty("proficiencyLevel")]
        public string ProficiencyLevel { get; set; } = "beginner"; // "beginner", "intermediate", "advanced", "expert"

        [FirestoreProperty("yearsOfExperience")]
        public int? YearsOfExperience { get; set; }

        [FirestoreProperty("lastUsed")]
        public DateTime? LastUsed { get; set; }

        [FirestoreProperty("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [FirestoreProperty("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}