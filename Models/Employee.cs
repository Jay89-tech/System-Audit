using Google.Cloud.Firestore;

namespace SkillsAuditSystem.Models
{
    [FirestoreData]
    public class Employee
    {
        [FirestoreProperty("id")]
        public string Id { get; set; } = string.Empty;

        [FirestoreProperty("uid")]
        public string Uid { get; set; } = string.Empty; // Firebase Auth UID

        [FirestoreProperty("name")]
        public string Name { get; set; } = string.Empty;

        [FirestoreProperty("email")]
        public string Email { get; set; } = string.Empty;

        [FirestoreProperty("cellNumber")]
        public string CellNumber { get; set; } = string.Empty;

        [FirestoreProperty("profession")]
        public string Profession { get; set; } = string.Empty;

        [FirestoreProperty("role")]
        public string Role { get; set; } = "employee"; // "employee" or "admin"

        [FirestoreProperty("profileImageUrl")]
        public string? ProfileImageUrl { get; set; }

        [FirestoreProperty("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [FirestoreProperty("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [FirestoreProperty("isActive")]
        public bool IsActive { get; set; } = true;

        // Navigation properties (not stored in Firestore directly)
        public List<Qualification>? Qualifications { get; set; }
        public List<Training>? Trainings { get; set; }
        public List<Skill>? Skills { get; set; }
    }
}