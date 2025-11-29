import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/certificate_model.dart';
import '../constants.dart';

class CertificateProvider with ChangeNotifier {
  CertificateResponseModel? _certificateData;
  bool _isLoading = false;
  String _error = '';
  String _selectedTemplateUrl = '';
  int _selectedTemplateIndex = 0;
  bool _isGenerating = false;
  String _generationError = '';
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  int _selectedTemplateId = 1;

  // Getters
  CertificateResponseModel? get certificateData => _certificateData;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedTemplateUrl => _selectedTemplateUrl;
  int get selectedTemplateIndex => _selectedTemplateIndex;
  bool get isGenerating => _isGenerating;
  String get generationError => _generationError;
  double get downloadProgress => _downloadProgress;
  bool get isDownloading => _isDownloading;
  int get selectedTemplateId => _selectedTemplateId;

  // List<CertificateCourseModel> get completedCourses =>
  //     _certificateData?.completedCourses ?? [];

  List<String> get allTemplates =>
      _certificateData?.certificates.map((e) => e.templateImage).toList() ?? [];

  // Get auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Clear error messages
  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearGenerationError() {
    _generationError = '';
    notifyListeners();
  }

  // Select certificate template
  void selectTemplate(int index) {
    if (_certificateData != null && index >= 0 && index < allTemplates.length) {
      _selectedTemplateIndex = index;
      _selectedTemplateUrl =
          _certificateData!.certificates[index].templateImage;
      _selectedTemplateId = _certificateData!.certificates[index].id;
      notifyListeners();
      print('=== Certificate Template Selected ===');
      print('Index: $index');
      print('Template URL: $_selectedTemplateUrl');
    }
  }

  // Fetch certificate templates and courses
  Future<void> fetchCertificateData() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('=== Fetching Certificate Data ===');
      print('API URL: $baseUrl/api/certificate_template');

      final token = await _getAuthToken();
      print('Auth Token: ${token != null ? 'Present $token' : 'Missing'}');

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/certificate_template'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          _certificateData = CertificateResponseModel.fromJson(responseData);

          // Set default template selection
          if (_certificateData!.certificates.isNotEmpty) {
            _selectedTemplateIndex = 0;
            _selectedTemplateUrl =
                _certificateData!.certificates[0].templateImage;
          }

          print('Certificate data loaded successfully');
          print(
              'Templates available: ${_certificateData!.certificates.length}');
          print('Completed courses: ${_certificateData!.syllabus.length}');
        } else {
          throw Exception('API returned success: false');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
            'Failed to load certificate data. Status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching certificate data: $error');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Bulk generate certificates
  Future<Map<String, dynamic>> bulkGenerateCertificates(
      List<CertificateGenerateRequestModel> requests) async {
    int successCount = 0;
    int failureCount = 0;
    List<Map<String, dynamic>> results = [];

    try {
      _isGenerating = true;
      _generationError = '';
      notifyListeners();

      print('=== Bulk Certificate Generation Started ===');
      print('Total certificates to generate: ${requests.length}');

      for (int i = 0; i < requests.length; i++) {
        final request = requests[i];
        print('\n--- Processing Certificate ${i + 1}/${requests.length} ---');
        print('Student: ${request.studentName}');
        print('Course: ${request.syllabusTitle}');

        try {
          final success = await _generateSingleCertificate(request);
          if (success) {
            successCount++;
            results.add({
              'index': i + 1,
              'student_name': request.studentName,
              'status': 'success',
              'message': 'Certificate generated successfully'
            });
            print('✅ Success for ${request.studentName}');
          } else {
            failureCount++;
            results.add({
              'index': i + 1,
              'student_name': request.studentName,
              'status': 'failed',
              'message': _generationError.isNotEmpty
                  ? _generationError
                  : 'Unknown error'
            });
            print('❌ Failed for ${request.studentName}: $_generationError');
          }
        } catch (e) {
          failureCount++;
          results.add({
            'index': i + 1,
            'student_name': request.studentName,
            'status': 'failed',
            'message': e.toString()
          });
          print('❌ Error for ${request.studentName}: $e');
        }

        // Add a small delay between requests to avoid overwhelming the server
        if (i < requests.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      print('\n=== Bulk Generation Summary ===');
      print('Total Processed: ${requests.length}');
      print('Successful: $successCount');
      print('Failed: $failureCount');
      print(
          'Success Rate: ${((successCount / requests.length) * 100).toStringAsFixed(1)}%');

      return {
        'total': requests.length,
        'success': successCount,
        'failed': failureCount,
        'success_rate':
            ((successCount / requests.length) * 100).toStringAsFixed(1),
        'results': results
      };
    } catch (error) {
      print('Error in bulk generation: $error');
      _generationError = error.toString();
      return {
        'total': requests.length,
        'success': successCount,
        'failed':
            failureCount + (requests.length - successCount - failureCount),
        'success_rate': '0.0',
        'results': results,
        'error': error.toString()
      };
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // Helper method for single certificate generation (extracted from main method)
  Future<bool> _generateSingleCertificate(
      CertificateGenerateRequestModel request,
      {bool downloadAfterGeneration = false}) async {
    try {
      print('=== Generating Single Certificate ===');
      print('API URL: $baseUrl/api/generate_certificate');

      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      http.Response response;

      // Check if student photo is provided for multipart request
      if (request.studentPhoto != null) {
        // Use multipart request for file upload
        var multipartRequest = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/api/generate_certificate'),
        );

        // Add headers
        multipartRequest.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

        // Add form fields
        multipartRequest.fields.addAll({
          'template_id': request.templateId.toString(),
          'syllabus_id': request.syllabusId.toString(),
          'course_duration': request.courseDuration,
          'phone': request.mobileNumber,
          'student_name': request.studentName,
          'father_name': request.fatherName,
          'syllabus_title': request.syllabusTitle,
          'course_completion_date': request.courseCompletionDate,
          'certificate_download_date': request.certificateDownloadDate,
          'course_level': request.courseLevel,
        });

        // Print the form data being sent
        print('=== Certificate Form Data ===');
        print('template_id: ${request.templateId.toString()}');
        print('syllabus_id: ${request.syllabusId.toString()}');
        print('course_duration: ${request.courseDuration}');
        print('phone: ${request.mobileNumber}');
        print('student_name: ${request.studentName}');
        print('father_name: ${request.fatherName}');
        print('syllabus_title: ${request.syllabusTitle}');
        print('course_completion_date: ${request.courseCompletionDate}');
        print('certificate_download_date: ${request.certificateDownloadDate}');
        print('course_level: ${request.courseLevel}');
        print('================================');

        // Add student photo file
        if (request.studentPhoto != null &&
            request.studentPhoto.path != null &&
            request.studentPhoto.path.isNotEmpty) {
          try {
            var photoFile = await http.MultipartFile.fromPath(
              'photo',
              request.studentPhoto.path,
              filename: 'student_photo.jpg',
            );
            multipartRequest.files.add(photoFile);
            print(
                'Student photo added to multipart request: ${request.studentPhoto.path}');
          } catch (e) {
            print('Error adding photo to request: $e');
            throw Exception('Failed to attach student photo: ${e.toString()}');
          }
        }

        print('Sending multipart request with student photo...');
        var streamedResponse = await multipartRequest.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Use regular JSON request without photo
        var requestData = request.toJson();
        requestData.remove('photo'); // Remove null photo field

        // Print the form data being sent
        print('=== Certificate JSON Data ===');
        print('template_id: ${request.templateId.toString()}');
        print('syllabus_id: ${request.syllabusId.toString()}');
        print('course_duration: ${request.courseDuration}');
        print('phone: ${request.mobileNumber}');
        print('student_name: ${request.studentName}');
        print('father_name: ${request.fatherName}');
        print('syllabus_title: ${request.syllabusTitle}');
        print('course_completion_date: ${request.courseCompletionDate}');
        print('certificate_download_date: ${request.certificateDownloadDate}');
        print('course_level: ${request.courseLevel}');
        print('================================');

        response = await http.post(
          Uri.parse('$baseUrl/api/generate_certificate'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(requestData),
        );
      }

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true &&
            responseData['download_url'] != null) {
          final downloadUrl = responseData['download_url'] as String;
          print('Certificate download URL: $downloadUrl');

          // Download the certificate if requested (for single certificate generation)
          if (downloadAfterGeneration) {
            final downloadSuccess =
                await _downloadCertificate(downloadUrl, request.syllabusTitle);
            return downloadSuccess;
          }

          return true; // Return true for successful generation without download
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to generate certificate');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to generate certificate. Status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error generating single certificate: $error');
      _generationError = error.toString();
      return false;
    }
  }

  // Generate and download certificate
  Future<bool> generateCertificate(
      CertificateGenerateRequestModel request) async {
    try {
      _isGenerating = true;
      _generationError = '';
      notifyListeners();

      final success = await _generateSingleCertificate(request,
          downloadAfterGeneration: true);

      if (success) {
        // Only attempt download for single certificate generation
        // Get the download URL from the last successful response
        print('Certificate generated successfully, attempting download...');

        // Note: You might need to modify this to get the actual download URL
        // from the response. For now, this assumes the URL is available.
        // You may need to store the download URL in a class variable
        // during the _generateSingleCertificate call.

        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Error in generateCertificate: $error');
      _generationError = error.toString();
      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // Download certificate file using flutter_file_downloader
  Future<bool> _downloadCertificate(
      String downloadUrl, String courseTitle) async {
    try {
      print('=== Downloading Certificate ===');
      print('Download URL: $downloadUrl');
      print('Course Title: $courseTitle');
      _isDownloading = true;
      _downloadProgress = 0.0;
      notifyListeners();

      // Get auth token for headers
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename =
          'Certificate_${courseTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_$timestamp.pdf';

      print('Download filename: $filename');

      // Use URL launcher to open the download URL in browser
      print('Opening download URL in browser: $downloadUrl');

      try {
        final uri = Uri.parse(downloadUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.inAppBrowserView,
          );
          print('✅ Download URL opened successfully in browser');
          _downloadProgress = 1.0;
          notifyListeners();
          return true;
        } else {
          throw Exception('Cannot launch URL: $downloadUrl');
        }
      } catch (e) {
        print('❌ Error launching URL: $e');
        throw Exception('Failed to open download URL: $e');
      }

      // // Use flutter_file_downloader to download the file
      // final downloadedFile = await FileDownloader.downloadFile(
      //   url: downloadUrl,
      //   name: filename,
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //   },
      //   onProgress: (String? fileName, double progress) {
      //     _downloadProgress = progress;
      //     notifyListeners();
      //     print('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
      //   },
      //   onDownloadCompleted: (String path) {
      //     print('Certificate downloaded successfully to: $path');
      //     _downloadProgress = 1.0;
      //     notifyListeners();
      //   },
      //   onDownloadError: (String error) {
      //     print('Download error: $error');
      //     throw Exception('Download failed: $error');
      //   },
      // );

      // if (downloadedFile != null) {
      //   print('Certificate file downloaded: ${downloadedFile.path}');
      //   _downloadProgress = 1.0;
      //   notifyListeners();
      //   return true;
      // } else {
      //   throw Exception('Failed to download certificate file');
      // }
    } catch (error) {
      print('Error downloading certificate: $error');
      _generationError = 'Download failed: ${error.toString()}';
      return false;
    } finally {
      _isDownloading = false;
      _downloadProgress = 0.0;
      notifyListeners();
    }
  }

  // Reset provider state
  void reset() {
    _certificateData = null;
    _isLoading = false;
    _error = '';
    _selectedTemplateUrl = '';
    _selectedTemplateIndex = 0;
    _isGenerating = false;
    _generationError = '';
    _downloadProgress = 0.0;
    _isDownloading = false;
    notifyListeners();
  }
}
