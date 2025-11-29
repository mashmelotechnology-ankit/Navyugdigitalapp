import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/slider_model.dart';

class SliderProvider extends ChangeNotifier {
  List<SliderModel> _sliders = [];
  bool _isLoading = false;
  String _error = '';

  List<SliderModel> get sliders => _sliders;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchSliders() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/api/sliders');
      if (kDebugMode) {
        print('Fetching sliders from: $url');
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (kDebugMode) {
          print('Sliders API response: $jsonData');
        }

        if (jsonData['success'] == true) {
          final List<dynamic> slidersData = jsonData['data'];
          _sliders = slidersData
              .map((slider) => SliderModel.fromJson(slider))
              .where((slider) => slider.status) // Only show active sliders
              .toList();

          // Sort by sort field
          _sliders.sort((a, b) => a.sort.compareTo(b.sort));

          if (kDebugMode) {
            print('Loaded ${_sliders.length} active sliders');
          }
        } else {
          _error = 'Failed to load sliders';
        }
      } else {
        _error = 'Failed to load sliders. Status: ${response.statusCode}';
      }
    } catch (error) {
      _error = 'Network error: $error';
      if (kDebugMode) {
        print('Error fetching sliders: $error');
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
