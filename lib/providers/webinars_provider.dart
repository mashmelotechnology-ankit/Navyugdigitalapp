import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/webinar_model.dart';

class WebinarsProvider extends ChangeNotifier {
  List<WebinarModel> _webinars = [];
  bool _isLoading = false;
  String _error = '';

  List<WebinarModel> get webinars => _webinars;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Get live webinars
  List<WebinarModel> get liveWebinars =>
      _webinars.where((w) => w.isLive).toList();

  // Get upcoming webinars
  List<WebinarModel> get upcomingWebinars =>
      _webinars.where((w) => w.isUpcoming).toList();

  Future<void> fetchWebinars() async {
    print('=== Starting fetchWebinars ===');
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString("access_token");
      final url = Uri.parse('$baseUrl/api/webinars');
      print('Fetching webinars from: $url');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      print('Webinars API Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          // Handle paginated response structure
          final Map<String, dynamic> dataWrapper = jsonData['data'];
          final List<dynamic> webinarsData = dataWrapper['data'];
          print('Raw webinars data count: ${webinarsData.length}');

          _webinars = [];
          for (var webinarData in webinarsData) {
            try {
              print('Processing webinar data: $webinarData');
              final webinar = WebinarModel.fromJson(webinarData);
              if (webinar.status) {
                print('Adding webinar: ${webinar.title}');
                print('Video URL: ${webinar.videoFile}');
                _webinars.add(webinar);
              }
            } catch (e) {
              print('Error parsing webinar: $e');
              print('Webinar data: $webinarData');
            }
          }

          print('Fetched ${_webinars.length} active webinars');
          for (var webinar in _webinars) {
            print(
                'Webinar: ${webinar.title}, Live: ${webinar.isLive}, Upcoming: ${webinar.isUpcoming}');
          }
        } else {
          _error = 'Failed to load webinars';
          print('API returned success: false');
        }
      } else {
        _error = 'Failed to load webinars. Status: ${response.statusCode}';
        print('API error: ${response.statusCode}');
      }
    } catch (error) {
      _error = 'Network error: $error';
      print('Error fetching webinars: $error');
    }

    _isLoading = false;
    print(
        '=== Finished fetchWebinars, webinars count: ${_webinars.length} ===');
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
