using Google.Cloud.Storage.V1;

namespace SkillsAuditSystem.Services
{
    public class StorageService : IStorageService
    {
        private readonly StorageClient _storageClient;
        private readonly string _bucketName;
        private readonly ILogger<StorageService> _logger;

        public StorageService(IConfiguration configuration, ILogger<StorageService> logger)
        {
            _logger = logger;
            _bucketName = configuration["Firebase:StorageBucket"] ?? throw new Exception("Storage bucket not configured");
            _storageClient = StorageClient.Create();
        }

        public async Task<(bool Success, string Url, string Message)> UploadFileAsync(Stream fileStream, string fileName, string folder)
        {
            try
            {
                var objectName = $"{folder}/{Guid.NewGuid()}_{fileName}";
                
                var uploadedObject = await _storageClient.UploadObjectAsync(
                    _bucketName,
                    objectName,
                    null,
                    fileStream
                );

                // Generate public URL
                var url = $"https://storage.googleapis.com/{_bucketName}/{objectName}";
                
                _logger.LogInformation($"File uploaded successfully: {objectName}");
                return (true, url, "File uploaded successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error uploading file: {ex.Message}");
                return (false, string.Empty, "Failed to upload file");
            }
        }

        public async Task<bool> DeleteFileAsync(string fileUrl)
        {
            try
            {
                // Extract object name from URL
                var uri = new Uri(fileUrl);
                var objectName = uri.AbsolutePath.TrimStart('/').Replace($"{_bucketName}/", "");

                await _storageClient.DeleteObjectAsync(_bucketName, objectName);
                
                _logger.LogInformation($"File deleted successfully: {objectName}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting file: {ex.Message}");
                return false;
            }
        }

        public async Task<string?> GetDownloadUrlAsync(string filePath)
        {
            try
            {
                var url = $"https://storage.googleapis.com/{_bucketName}/{filePath}";
                return await Task.FromResult(url);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting download URL: {ex.Message}");
                return null;
            }
        }

        public async Task<(bool Success, string Url, string Message)> UploadCertificateAsync(Stream fileStream, string fileName, string employeeId)
        {
            var folder = $"certificates/{employeeId}";
            return await UploadFileAsync(fileStream, fileName, folder);
        }

        public async Task<(bool Success, string Url, string Message)> UploadProfileImageAsync(Stream fileStream, string fileName, string employeeId)
        {
            var folder = $"profiles/{employeeId}";
            return await UploadFileAsync(fileStream, fileName, folder);
        }
    }
}