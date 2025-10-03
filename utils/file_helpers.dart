import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'constants.dart';
import 'validators.dart';

class FileHelpers {
  static final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Validate file size
        final file = File(image.path);
        final fileSize = await file.length();

        if (!Validators.validateFileSize(
            fileSize, AppConstants.maxImageSizeMB)) {
          debugPrint('Image file too large: ${formatFileSize(fileSize)}');
          return null;
        }

        // Validate file extension
        if (!Validators.validateFileExtension(
            image.name, AppConstants.allowedImageExtensions)) {
          debugPrint('Invalid image file extension');
          return null;
        }
      }

      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // Take photo with camera
  static Future<XFile?> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        if (!Validators.validateFileSize(
            fileSize, AppConstants.maxImageSizeMB)) {
          debugPrint('Photo file too large: ${formatFileSize(fileSize)}');
          return null;
        }
      }

      return image;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  // Pick document/certificate file
  static Future<PlatformFile?> pickCertificateFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedCertificateExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file size
        if (file.size > AppConstants.maxCertificateSizeMB * 1024 * 1024) {
          debugPrint(
              'Certificate file too large: ${formatFileSize(file.size)}');
          return null;
        }

        // Validate extension
        final extension = file.extension?.toLowerCase() ?? '';
        if (!AppConstants.allowedCertificateExtensions.contains(extension)) {
          debugPrint('Invalid certificate file extension: $extension');
          return null;
        }

        return file;
      }

      return null;
    } catch (e) {
      debugPrint('Error picking certificate file: $e');
      return null;
    }
  }

  // Get file extension
  static String getFileExtension(String fileName) {
    return path.extension(fileName).toLowerCase();
  }

  // Get file name without extension
  static String getFileNameWithoutExtension(String fileName) {
    return path.basenameWithoutExtension(fileName);
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // Check if file is image
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName).replaceAll('.', '');
    return AppConstants.allowedImageExtensions.contains(extension);
  }

  // Check if file is PDF
  static bool isPdfFile(String fileName) {
    return getFileExtension(fileName) == '.pdf';
  }

  // Generate unique file name
  static String generateUniqueFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = getFileExtension(originalName);
    final nameWithoutExt = getFileNameWithoutExtension(originalName);
    return '${nameWithoutExt}_$timestamp$extension';
  }

  // Clean file name (remove special characters)
  static String cleanFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
  }

  // Get file size from XFile
  static Future<int> getXFileSize(XFile file) async {
    final fileData = File(file.path);
    return await fileData.length();
  }

  // Get file size from PlatformFile
  static int getPlatformFileSize(PlatformFile file) {
    return file.size;
  }

  // Delete file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  // Check if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking file existence: $e');
      return false;
    }
  }

  // Get MIME type
  static String getMimeType(String fileName) {
    final extension =
        getFileExtension(fileName).replaceAll('.', '').toLowerCase();

    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  // Compress image (placeholder - requires image package)
  static Future<File?> compressImage(File imageFile, {int quality = 85}) async {
    try {
      // TODO: Implement actual compression using flutter_image_compress package
      // For now, return the original file
      return imageFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  // Convert XFile to File
  static Future<File> xFileToFile(XFile xFile) async {
    return File(xFile.path);
  }

  // Read file as bytes
  static Future<Uint8List?> readFileAsBytes(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Error reading file as bytes: $e');
      return null;
    }
  }

  // Save bytes to file
  static Future<File?> saveBytesToFile(Uint8List bytes, String filePath) async {
    try {
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error saving bytes to file: $e');
      return null;
    }
  }

  // Get temporary directory path
  static Future<String> getTempDirectoryPath() async {
    try {
      final directory = Directory.systemTemp;
      return directory.path;
    } catch (e) {
      debugPrint('Error getting temp directory: $e');
      return '';
    }
  }

  // Create temporary file
  static Future<File?> createTempFile(String fileName) async {
    try {
      final tempDir = await getTempDirectoryPath();
      final tempFilePath = path.join(tempDir, fileName);
      final tempFile = File(tempFilePath);
      return tempFile;
    } catch (e) {
      debugPrint('Error creating temp file: $e');
      return null;
    }
  }
}

// File validation class
class FileValidation {
  static bool validateImageFile(XFile? file) {
    if (file == null) return false;
    return FileHelpers.isImageFile(file.name);
  }

  static bool validateCertificateFile(PlatformFile? file) {
    if (file == null) return false;

    final extension = file.extension?.toLowerCase() ?? '';
    return AppConstants.allowedCertificateExtensions.contains(extension);
  }

  static Future<bool> validateImageSize(XFile file) async {
    final size = await FileHelpers.getXFileSize(file);
    return Validators.validateFileSize(size, AppConstants.maxImageSizeMB);
  }

  static bool validateCertificateSize(PlatformFile file) {
    return Validators.validateFileSize(
        file.size, AppConstants.maxCertificateSizeMB);
  }
}

// Extension methods
extension XFileExtension on XFile {
  Future<int> get sizeInBytes async => await FileHelpers.getXFileSize(this);
  String get extension => FileHelpers.getFileExtension(name);
  bool get isImage => FileHelpers.isImageFile(name);
  bool get isPdf => FileHelpers.isPdfFile(name);
  String get mimeType => FileHelpers.getMimeType(name);
}

extension PlatformFileExtension on PlatformFile {
  String get sizeFormatted => FileHelpers.formatFileSize(size);
  bool get isImage => FileHelpers.isImageFile(name);
  bool get isPdf => FileHelpers.isPdfFile(name);
  String get mimeType => FileHelpers.getMimeType(name);
}
