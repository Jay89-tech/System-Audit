namespace SkillsAuditSystem.Services
{
    public interface INotificationService
    {
        /// <summary>
        /// Send notification to a specific employee by their UID
        /// </summary>
        Task<bool> SendNotificationToEmployeeAsync(string employeeUid, string title, string body, Dictionary<string, string>? data = null);

        /// <summary>
        /// Send notification to multiple employees
        /// </summary>
        Task<bool> SendNotificationToMultipleAsync(List<string> employeeUids, string title, string body, Dictionary<string, string>? data = null);

        /// <summary>
        /// Send qualification approval notification
        /// </summary>
        Task<bool> SendQualificationApprovedNotificationAsync(string employeeUid, string qualificationName);

        /// <summary>
        /// Send qualification rejection notification
        /// </summary>
        Task<bool> SendQualificationRejectedNotificationAsync(string employeeUid, string qualificationName, string reason);

        /// <summary>
        /// Send training suggestion notification
        /// </summary>
        Task<bool> SendTrainingSuggestedNotificationAsync(string employeeUid, string trainingName);

        /// <summary>
        /// Send profile update approval notification
        /// </summary>
        Task<bool> SendProfileUpdateNotificationAsync(string employeeUid, string message);
    }
}