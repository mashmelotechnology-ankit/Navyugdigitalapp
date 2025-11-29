import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/live_m_class_model.dart';

class LiveClassesProvider extends ChangeNotifier {
  List<LiveMClassModel> _liveClasses = [];
  bool _isLoading = false;
  String _error = '';

  List<LiveMClassModel> get liveClasses => _liveClasses;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Get live classes that are currently live
  List<LiveMClassModel> get currentlyLive =>
      _liveClasses.where((c) => c.isLive).toList();

  // Get upcoming live classes
  List<LiveMClassModel> get upcomingClasses =>
      _liveClasses.where((c) => c.isUpcoming).toList();

  Future<void> fetchLiveClasses() async {
    print('=== Starting fetchLiveClasses ===');
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/api/live_m_class');
      print('Fetching live classes from: $url');
      final response = await http.get(url);

      print('Live Classes API Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          // Handle paginated response structure
          final Map<String, dynamic> dataWrapper = jsonData['data'];
          final List<dynamic> classesData = dataWrapper['data'];
          print('Raw live classes data count: ${classesData.length}');

          _liveClasses = [];
          for (var classData in classesData) {
            try {
              print('Processing live class data: $classData');
              final liveClass = LiveMClassModel.fromJson(classData);
              if (liveClass.status) {
                print('Adding live class: ${liveClass.title}');
                print('Video URL: ${liveClass.videoFile}');
                _liveClasses.add(liveClass);
              }
            } catch (e) {
              print('Error parsing live class: $e');
              print('Live class data: $classData');
            }
          }

          print('Fetched ${_liveClasses.length} active live classes');
          for (var liveClass in _liveClasses) {
            print(
                'Live Class: ${liveClass.title}, Live: ${liveClass.isLive}, Upcoming: ${liveClass.isUpcoming}');
          }
        } else {
          _error = 'Failed to load live classes';
          print('API returned success: false');
        }
      } else {
        _error = 'Failed to load live classes. Status: ${response.statusCode}';
        print('API error: ${response.statusCode}');
      }
    } catch (error) {
      _error = 'Network error: $error';
      print('Error fetching live classes: $error');
    }

    _isLoading = false;
    print(
        '=== Finished fetchLiveClasses, live classes count: ${_liveClasses.length} ===');
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
