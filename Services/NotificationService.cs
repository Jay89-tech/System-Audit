using FirebaseAdmin.Messaging;

namespace SkillsAuditSystem.Services
{
    public class NotificationService : INotificationService
    {
        private readonly ILogger<NotificationService> _logger;

        public NotificationService(ILogger<NotificationService> logger)
        {
            _logger = logger;
        }

        public async Task<bool> SendNotificationToEmployeeAsync(string employeeUid, string title, string body, Dictionary<string, string>? data = null)
        {
            try
            {
                // In production, you would store FCM tokens in Firestore per employee
                // For now, we'll use topic-based messaging with employee UID as topic
                
                var message = new Message
                {
                    Notification = new Notification
                    {
                        Title = title,
                        Body = body
                    },
                    Data = data ?? new Dictionary<string, string>(),
                    Topic = $"employee_{employeeUid}"
                };

                var response = await FirebaseMessaging.DefaultInstance.SendAsync(message);
                
                _logger.LogInformation($"Notification sent successfully: {response}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error sending notification: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> SendNotificationToMultipleAsync(List<string> employeeUids, string title, string body, Dictionary<string, string>? data = null)
        {
            try
            {
                var tasks = employeeUids.Select(uid => 
                    SendNotificationToEmployeeAsync(uid, title, body, data)
                );

                var results = await Task.WhenAll(tasks);
                return results.All(r => r);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error sending multiple notifications: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> SendQualificationApprovedNotificationAsync(string employeeUid, string qualificationName)
        {
            var title = "Qualification Approved! 🎉";
            var body = $"Your {qualificationName} has been approved by HR.";
            var data = new Dictionary<string, string>
            {
                { "type", "qualification_approved" },
                { "qualificationName", qualificationName }
            };

            return await SendNotificationToEmployeeAsync(employeeUid, title, body, data);
        }

        public async Task<bool> SendQualificationRejectedNotificationAsync(string employeeUid, string qualificationName, string reason)
        {
            var title = "Qualification Update";
            var body = $"Your {qualificationName} requires additional review. Please check details.";
            var data = new Dictionary<string, string>
            {
                { "type", "qualification_rejected" },
                { "qualificationName", qualificationName },
                { "reason", reason }
            };

            return await SendNotificationToEmployeeAsync(employeeUid, title, body, data);
        }

        public async Task<bool> SendTrainingSuggestedNotificationAsync(string employeeUid, string trainingName)
        {
            var title = "New Training Suggested 📚";
            var body = $"HR has suggested a new training: {trainingName}";
            var data = new Dictionary<string, string>
            {
                { "type", "training_suggested" },
                { "trainingName", trainingName }
            };

            return await SendNotificationToEmployeeAsync(employeeUid, title, body, data);
        }

        public async Task<bool> SendProfileUpdateNotificationAsync(string employeeUid, string message)
        {
            var title = "Profile Updated";
            var body = message;
            var data = new Dictionary<string, string>
            {
                { "type", "profile_update" }
            };

            return await SendNotificationToEmployeeAsync(employeeUid, title, body, data);
        }
    }
}