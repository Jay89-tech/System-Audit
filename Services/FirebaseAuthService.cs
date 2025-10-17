using FirebaseAdmin.Auth;
using Google.Apis.Auth.OAuth2;
using Newtonsoft.Json;
using System.Text;
using SkillsAuditSystem.Models;
using SkillsAuditSystem.Services;

namespace SkillsAuditSystem.Services
{
    public class FirebaseAuthService : IFirebaseAuthService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<FirebaseAuthService> _logger;

        public FirebaseAuthService(IConfiguration configuration, ILogger<FirebaseAuthService> logger)
        {
            _configuration = configuration;
            _logger = logger;
            
        }

        public async Task<(bool Success, string Token, string Message)> SignInAsync(string email, string password)
        {
            try
            {
                var apiKey = _configuration["Firebase:ApiKey"];
                var payload = new
                {
                    email,
                    password,
                    returnSecureToken = true
                };

                using var client = new HttpClient();
                var content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json");

                var response = await client.PostAsync(
                    $"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={apiKey}",
                    content
                );

                var json = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    dynamic result = JsonConvert.DeserializeObject(json)!;
                    string token = result.idToken;
                    _logger.LogInformation($"User {email} signed in successfully.");
                    return (true, token, "Login successful");
                }

                _logger.LogWarning($"Login failed for {email}: {json}");
                return (false, string.Empty, "Invalid email or password");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Sign in error: {ex.Message}");
                return (false, string.Empty, "An error occurred during sign in");
            }
        }


        public async Task<(bool Success, string Uid, string Message)> CreateEmployeeAccountAsync(string email, string password, string displayName)
        {
            try
            {
                var userRecordArgs = new UserRecordArgs
                {
                    Email = email,
                    Password = password,
                    DisplayName = displayName,
                    EmailVerified = false,
                    Disabled = false
                };

                var userRecord = await FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance.CreateUserAsync(userRecordArgs);
                
                _logger.LogInformation($"Employee account created: {email} with UID: {userRecord.Uid}");
                return (true, userRecord.Uid, "Employee account created successfully");
            }
            catch (FirebaseAdmin.Auth.FirebaseAuthException ex)
            {
                _logger.LogError($"Firebase create user error: {ex.Message}");
                
                if (ex.Message.Contains("EMAIL_EXISTS"))
                {
                    return (false, string.Empty, "Email address already in use");
                }
                
                return (false, string.Empty, $"Failed to create account: {ex.Message}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Create account error: {ex.Message}");
                return (false, string.Empty, "An error occurred while creating the account");
            }
        }

        public async Task<(bool IsValid, string Uid, string Email)> VerifyTokenAsync(string idToken)
        {
            try
            {
                var decodedToken = await FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(idToken);
                
                if (decodedToken != null)
                {
                    return (true, decodedToken.Uid, decodedToken.Claims.ContainsKey("email") ? decodedToken.Claims["email"].ToString() ?? "" : "");
                }

                return (false, string.Empty, string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Token verification error: {ex.Message}");
                return (false, string.Empty, string.Empty);
            }
        }

        public async Task<bool> DeleteUserAsync(string uid)
        {
            try
            {
                await FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance.DeleteUserAsync(uid);
                _logger.LogInformation($"User deleted: {uid}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Delete user error: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdatePasswordAsync(string uid, string newPassword)
        {
            try
            {
                var userRecordArgs = new UserRecordArgs
                {
                    Uid = uid,
                    Password = newPassword
                };

                await FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance.UpdateUserAsync(userRecordArgs);
                _logger.LogInformation($"Password updated for user: {uid}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Update password error: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> SetUserStatusAsync(string uid, bool isDisabled)
        {
            try
            {
                var userRecordArgs = new UserRecordArgs
                {
                    Uid = uid,
                    Disabled = isDisabled
                };

                await FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance.UpdateUserAsync(userRecordArgs);
                _logger.LogInformation($"User {uid} status changed to {(isDisabled ? "disabled" : "enabled")}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Set user status error: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> SendPasswordResetEmailAsync(string email)
        {
            try
            {
                var link = await FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance.GeneratePasswordResetLinkAsync(email);
                
                // In production, send this link via email service
                _logger.LogInformation($"Password reset link generated for: {email}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Send password reset error: {ex.Message}");
                return false;
            }
        }
    }
}