import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/template_model.dart';

class TemplateEditorProvider extends ChangeNotifier {
  List<TemplateModel> _templates = [];
  List<String> _categories = ['All', 'Business', 'Social', 'Education', 'Event'];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  // Current editing template
  TemplateModel? _currentTemplate;
  String? _selectedElementId;
  bool _isEditing = false;

  // Getters
  List<TemplateModel> get templates => _templates;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TemplateModel? get currentTemplate => _currentTemplate;
  String? get selectedElementId => _selectedElementId;
  bool get isEditing => _isEditing;

  List<TemplateModel> get filteredTemplates {
    if (_selectedCategory == 'All') {
      return _templates;
    }
    return _templates.where((template) => template.category == _selectedCategory).toList();
  }

  // Template loading and management
  Future<void> loadTemplates() async {
    try {
      _setLoading(true);
      _error = null;

      // Load from JSON file
      final String response = await rootBundle.loadString('assets/data/templates.json');
      final Map<String, dynamic> data = json.decode(response);
      
      _templates = (data['templates'] as List)
          .map((templateJson) => TemplateModel.fromJson(templateJson))
          .toList();

      // Generate sample templates if no JSON exists
      if (_templates.isEmpty) {
        _generateSampleTemplates();
      }

      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load templates: $e';
      _generateSampleTemplates(); // Fallback to sample templates
      _setLoading(false);
    }
  }

  void _generateSampleTemplates() {
    _templates = [
      // Business Card Template
      TemplateModel(
        id: 'business_1',
        name: 'Business Card Pro',
        category: 'Business',
        thumbnailPath: 'assets/images/templates/business_card_thumb.png',
        backgroundImage: 'assets/images/templates/business_bg.png',
        size: TemplateSize(width: 350, height: 200),
        elements: [
          TemplateElementModel(
            id: 'title_1',
            type: ElementType.text,
            content: 'Your Name',
            position: ElementPosition(x: 20, y: 30),
            size: ElementSize(width: 200, height: 40),
            style: ElementStyle(
              fontSize: 24,
              isBold: true,
              color: '#1976D2',
              fontFamily: 'Poppins',
            ),
          ),
          TemplateElementModel(
            id: 'subtitle_1',
            type: ElementType.text,
            content: 'Professional Title',
            position: ElementPosition(x: 20, y: 80),
            size: ElementSize(width: 200, height: 30),
            style: ElementStyle(
              fontSize: 16,
              color: '#666666',
              fontFamily: 'Poppins',
            ),
          ),
          TemplateElementModel(
            id: 'contact_1',
            type: ElementType.text,
            content: 'contact@email.com',
            position: ElementPosition(x: 20, y: 120),
            size: ElementSize(width: 200, height: 25),
            style: ElementStyle(
              fontSize: 14,
              color: '#333333',
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),

      // Social Media Post Template
      TemplateModel(
        id: 'social_1',
        name: 'Instagram Story',
        category: 'Social',
        thumbnailPath: 'assets/images/templates/social_story_thumb.png',
        backgroundImage: 'assets/images/templates/gradient_bg.png',
        size: TemplateSize(width: 320, height: 568),
        elements: [
          TemplateElementModel(
            id: 'main_text_1',
            type: ElementType.text,
            content: 'Your Story Title',
            position: ElementPosition(x: 40, y: 200),
            size: ElementSize(width: 240, height: 80),
            style: ElementStyle(
              fontSize: 32,
              isBold: true,
              color: '#FFFFFF',
              fontFamily: 'Poppins',
              textAlign: 'center',
            ),
          ),
          TemplateElementModel(
            id: 'sub_text_1',
            type: ElementType.text,
            content: 'Add your message here',
            position: ElementPosition(x: 40, y: 300),
            size: ElementSize(width: 240, height: 60),
            style: ElementStyle(
              fontSize: 18,
              color: '#F0F0F0',
              fontFamily: 'Poppins',
              textAlign: 'center',
            ),
          ),
        ],
      ),

      // Event Flyer Template
      TemplateModel(
        id: 'event_1',
        name: 'Event Flyer',
        category: 'Event',
        thumbnailPath: 'assets/images/templates/event_flyer_thumb.png',
        backgroundImage: 'assets/images/templates/event_bg.png',
        size: TemplateSize(width: 400, height: 600),
        elements: [
          TemplateElementModel(
            id: 'event_title_1',
            type: ElementType.text,
            content: 'EVENT TITLE',
            position: ElementPosition(x: 50, y: 100),
            size: ElementSize(width: 300, height: 60),
            style: ElementStyle(
              fontSize: 28,
              isBold: true,
              color: '#FF5722',
              fontFamily: 'Poppins',
              textAlign: 'center',
            ),
          ),
          TemplateElementModel(
            id: 'event_date_1',
            type: ElementType.text,
            content: 'DECEMBER 25, 2025',
            position: ElementPosition(x: 50, y: 180),
            size: ElementSize(width: 300, height: 40),
            style: ElementStyle(
              fontSize: 20,
              color: '#333333',
              fontFamily: 'Poppins',
              textAlign: 'center',
            ),
          ),
          TemplateElementModel(
            id: 'event_desc_1',
            type: ElementType.text,
            content: 'Join us for an amazing experience!',
            position: ElementPosition(x: 50, y: 250),
            size: ElementSize(width: 300, height: 100),
            style: ElementStyle(
              fontSize: 16,
              color: '#666666',
              fontFamily: 'Poppins',
              textAlign: 'center',
            ),
          ),
        ],
      ),

      // Education Certificate Template
      TemplateModel(
        id: 'education_1',
        name: 'Certificate',
        category: 'Education',
        thumbnailPath: 'assets/images/templates/certificate_thumb.png',
        backgroundImage: 'assets/images/templates/certificate_bg.png',
        size: TemplateSize(width: 600, height: 400),
        elements: [
          TemplateElementModel(
            id: 'cert_title_1',
            type: ElementType.text,
            content: 'CERTIFICATE OF COMPLETION',
            position: ElementPosition(x: 100, y: 80),
            size: ElementSize(width: 400, height: 50),
            style: ElementStyle(
              fontSize: 26,
              isBold: true,
              color: '#1976D2',
              fontFamily: 'Poppins',
              textAlign: 'center',
            ),
          ),
          TemplateElementModel(
            id: 'cert_name_1',
            type: ElementType.text,
            content: 'Student Name',
            position: ElementPosition(x: 100, y: 180),
            size: ElementSize(width: 400, height: 40),
            style: ElementStyle(
              fontSize: 24,
              isBold: true,
              color: '#333333',
              fontFamily: 'Poppins',
              textAlign: 'center',
            ),
          ),
          TemplateElementModel(
            id: 'cert_course_1',
            type: ElementType.text,
            content: 'Course Name',
            position: ElementPosition(x: 100, y: 240),
            size: ElementSize(width: 400, height: 30),
            style: ElementStyle(
              fontSize: 18,
              color: '#666666',
              fontFamily: 'Poppins',
              textAlign: 'center',
            ),
          ),
        ],
      ),
    ];
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Template editing methods
  void startEditing(TemplateModel template) {
    _currentTemplate = template.copyWith();
    _selectedElementId = null;
    _isEditing = true;
    notifyListeners();
  }

  void selectElement(String elementId) {
    _selectedElementId = elementId;
    notifyListeners();
  }

  void updateElementContent(String elementId, String newContent) {
    if (_currentTemplate == null) return;

    final updatedElements = _currentTemplate!.elements.map((element) {
      if (element.id == elementId) {
        return element.copyWith(content: newContent);
      }
      return element;
    }).toList();

    _currentTemplate = _currentTemplate!.copyWith(elements: updatedElements);
    notifyListeners();
  }

  void updateElementPosition(String elementId, ElementPosition newPosition) {
    if (_currentTemplate == null) return;

    final updatedElements = _currentTemplate!.elements.map((element) {
      if (element.id == elementId) {
        return element.copyWith(position: newPosition);
      }
      return element;
    }).toList();

    _currentTemplate = _currentTemplate!.copyWith(elements: updatedElements);
    notifyListeners();
  }

  void updateElementSize(String elementId, ElementSize newSize) {
    if (_currentTemplate == null) return;

    final updatedElements = _currentTemplate!.elements.map((element) {
      if (element.id == elementId) {
        return element.copyWith(size: newSize);
      }
      return element;
    }).toList();

    _currentTemplate = _currentTemplate!.copyWith(elements: updatedElements);
    notifyListeners();
  }

  void updateElementStyle(String elementId, ElementStyle newStyle) {
    if (_currentTemplate == null) return;

    final updatedElements = _currentTemplate!.elements.map((element) {
      if (element.id == elementId) {
        return element.copyWith(style: newStyle);
      }
      return element;
    }).toList();

    _currentTemplate = _currentTemplate!.copyWith(elements: updatedElements);
    notifyListeners();
  }

  void addTextElement() {
    if (_currentTemplate == null) return;

    final newElement = TemplateElementModel(
      id: 'text_${DateTime.now().millisecondsSinceEpoch}',
      type: ElementType.text,
      content: 'New Text',
      position: ElementPosition(x: 50, y: 100),
      size: ElementSize(width: 150, height: 40),
      style: ElementStyle(
        fontSize: 16,
        color: '#333333',
        fontFamily: 'Poppins',
      ),
    );

    final updatedElements = [..._currentTemplate!.elements, newElement];
    _currentTemplate = _currentTemplate!.copyWith(elements: updatedElements);
    _selectedElementId = newElement.id;
    notifyListeners();
  }

  void deleteElement(String elementId) {
    if (_currentTemplate == null) return;

    final updatedElements = _currentTemplate!.elements
        .where((element) => element.id != elementId)
        .toList();

    _currentTemplate = _currentTemplate!.copyWith(elements: updatedElements);
    
    if (_selectedElementId == elementId) {
      _selectedElementId = null;
    }
    
    notifyListeners();
  }

  void clearSelection() {
    _selectedElementId = null;
    notifyListeners();
  }

  void stopEditing() {
    _currentTemplate = null;
    _selectedElementId = null;
    _isEditing = false;
    notifyListeners();
  }

  TemplateElementModel? getSelectedElement() {
    if (_currentTemplate == null || _selectedElementId == null) return null;
    
    try {
      return _currentTemplate!.elements
          .firstWhere((element) => element.id == _selectedElementId);
    } catch (e) {
      return null;
    }
  }

  void updateCurrentTemplate(TemplateModel updatedTemplate) {
    _currentTemplate = updatedTemplate;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}