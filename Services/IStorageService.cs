namespace SkillsAuditSystem.Services
{
    public interface IStorageService
    {
        /// <summary>
        /// Upload a file to Firebase Storage
        /// </summary>
        Task<(bool Success, string Url, string Message)> UploadFileAsync(Stream fileStream, string fileName, string folder);

        /// <summary>
        /// Delete a file from Firebase Storage
        /// </summary>
        Task<bool> DeleteFileAsync(string fileUrl);

        /// <summary>
        /// Get download URL for a file
        /// </summary>
        Task<string?> GetDownloadUrlAsync(string filePath);

        /// <summary>
        /// Upload certificate/document for qualification
        /// </summary>
        Task<(bool Success, string Url, string Message)> UploadCertificateAsync(Stream fileStream, string fileName, string employeeId);

        /// <summary>
        /// Upload profile image for employee
        /// </summary>
        Task<(bool Success, string Url, string Message)> UploadProfileImageAsync(Stream fileStream, string fileName, string employeeId);
    }
}