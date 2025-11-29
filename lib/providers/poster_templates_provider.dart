import 'package:flutter/material.dart';

class PosterTemplate {
  final String id;
  final String name;
  final String category;
  final Color color;
  final String? imagePath;
  final Map<String, dynamic>? designData;

  PosterTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    this.imagePath,
    this.designData,
  });
}

class PosterTemplatesProvider with ChangeNotifier {
  List<PosterTemplate> _templates = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;

  List<PosterTemplate> get templates => _templates;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  List<String> get categories {
    final categorySet = <String>{'All'};
    for (final template in _templates) {
      categorySet.add(template.category);
    }
    return categorySet.toList();
  }

  List<PosterTemplate> get filteredTemplates {
    if (_selectedCategory == 'All') {
      return _templates;
    }
    return _templates
        .where((template) => template.category == _selectedCategory)
        .toList();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void generateTemplates() {
    if (_isLoading || _templates.isNotEmpty) return; // Prevent multiple calls
    
    _isLoading = true;
    notifyListeners();
    
    _templates = [
      // Social Media Templates
      PosterTemplate(
        id: 'social_1',
        name: 'Instagram Post',
        category: 'Social Media',
        color: const Color(0xFF667eea),
      ),
      PosterTemplate(
        id: 'social_2',
        name: 'Facebook Cover',
        category: 'Social Media',
        color: Colors.blue,
      ),
      PosterTemplate(
        id: 'social_3',
        name: 'Twitter Header',
        category: 'Social Media',
        color: Colors.lightBlue,
      ),
      PosterTemplate(
        id: 'social_4',
        name: 'LinkedIn Post',
        category: 'Social Media',
        color: Colors.indigo,
      ),

      // Business Templates
      PosterTemplate(
        id: 'business_1',
        name: 'Business Card',
        category: 'Business',
        color: Colors.grey[800]!,
      ),
      PosterTemplate(
        id: 'business_2',
        name: 'Flyer',
        category: 'Business',
        color: Colors.orange,
      ),
      PosterTemplate(
        id: 'business_3',
        name: 'Brochure',
        category: 'Business',
        color: Colors.teal,
      ),
      PosterTemplate(
        id: 'business_4',
        name: 'Presentation',
        category: 'Business',
        color: Colors.purple,
      ),

      // Marketing Templates
      PosterTemplate(
        id: 'marketing_1',
        name: 'Sale Banner',
        category: 'Marketing',
        color: Colors.red,
      ),
      PosterTemplate(
        id: 'marketing_2',
        name: 'Product Ad',
        category: 'Marketing',
        color: Colors.pink,
      ),
      PosterTemplate(
        id: 'marketing_3',
        name: 'Event Poster',
        category: 'Marketing',
        color: Colors.deepOrange,
      ),
      PosterTemplate(
        id: 'marketing_4',
        name: 'Promotional',
        category: 'Marketing',
        color: Colors.amber,
      ),

      // Education Templates
      PosterTemplate(
        id: 'education_1',
        name: 'Course Banner',
        category: 'Education',
        color: Colors.green,
      ),
      PosterTemplate(
        id: 'education_2',
        name: 'Certificate',
        category: 'Education',
        color: Colors.blue[800]!,
      ),
      PosterTemplate(
        id: 'education_3',
        name: 'Infographic',
        category: 'Education',
        color: Colors.cyan,
      ),
      PosterTemplate(
        id: 'education_4',
        name: 'Study Guide',
        category: 'Education',
        color: Colors.lightGreen,
      ),

      // Personal Templates
      PosterTemplate(
        id: 'personal_1',
        name: 'Birthday Card',
        category: 'Personal',
        color: Colors.pinkAccent,
      ),
      PosterTemplate(
        id: 'personal_2',
        name: 'Wedding Invite',
        category: 'Personal',
        color: const Color(0xFFf093fb),
      ),
      PosterTemplate(
        id: 'personal_3',
        name: 'Thank You Card',
        category: 'Personal',
        color: Colors.purple[300]!,
      ),
      PosterTemplate(
        id: 'personal_4',
        name: 'Greeting Card',
        category: 'Personal',
        color: Colors.orange[300]!,
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }

  void addTemplate(PosterTemplate template) {
    _templates.add(template);
    notifyListeners();
  }

  void removeTemplate(String id) {
    _templates.removeWhere((template) => template.id == id);
    notifyListeners();
  }

  PosterTemplate? getTemplateById(String id) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }
}
