import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/topic_model.dart';

class TopicsProvider extends ChangeNotifier {
  List<TopicModel> _topics = [];
  bool _isLoading = false;
  String _error = '';

  List<TopicModel> get topics => _topics;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchTopics() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/api/topics');
      if (kDebugMode) {
        print('Fetching topics from: $url');
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (kDebugMode) {
          print('Topics API response: $jsonData');
        }

        if (jsonData['success'] == true) {
          final List<dynamic> topicsData = jsonData['data'];
          _topics = topicsData
              .map((topic) => TopicModel.fromJson(topic))
              .where((topic) => topic.status) // Only show active topics
              .toList();

          if (kDebugMode) {
            print('Loaded ${_topics.length} active topics');
          }
        } else {
          _error = 'Failed to load topics';
        }
      } else {
        _error = 'Failed to load topics. Status: ${response.statusCode}';
      }
    } catch (error) {
      _error = 'Network error: $error';
      if (kDebugMode) {
        print('Error fetching topics: $error');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
