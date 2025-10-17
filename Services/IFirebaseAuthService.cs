using SkillsAuditSystem.Models;

namespace SkillsAuditSystem.Services
{
    public interface IFirebaseAuthService
    {
        /// <summary>
        /// Authenticate admin user with email and password
        /// </summary>
        Task<(bool Success, string Token, string Message)> SignInAsync(string email, string password);

        /// <summary>
        /// Create a new employee account in Firebase Authentication
        /// </summary>
        Task<(bool Success, string Uid, string Message)> CreateEmployeeAccountAsync(string email, string password, string displayName);

        /// <summary>
        /// Verify Firebase ID token
        /// </summary>
        Task<(bool IsValid, string Uid, string Email)> VerifyTokenAsync(string idToken);

        /// <summary>
        /// Delete employee account from Firebase Authentication
        /// </summary>
        Task<bool> DeleteUserAsync(string uid);

        /// <summary>
        /// Update employee password
        /// </summary>
        Task<bool> UpdatePasswordAsync(string uid, string newPassword);

        /// <summary>
        /// Disable or enable user account
        /// </summary>
        Task<bool> SetUserStatusAsync(string uid, bool isDisabled);

        /// <summary>
        /// Send password reset email
        /// </summary>
        Task<bool> SendPasswordResetEmailAsync(string email);
    }
}