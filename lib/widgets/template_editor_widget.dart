import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants.dart';
import '../models/template_model.dart';
import '../providers/template_editor_provider.dart';
import '../utils/template_export_util.dart';
import '../widgets/template_element_widget.dart';
import '../widgets/template_editor_toolbar.dart';

class TemplateEditorWidget extends StatefulWidget {
  final TemplateModel initialTemplate;

  const TemplateEditorWidget({
    Key? key,
    required this.initialTemplate,
  }) : super(key: key);

  @override
  State<TemplateEditorWidget> createState() => _TemplateEditorWidgetState();
}

class _TemplateEditorWidgetState extends State<TemplateEditorWidget> {
  final GlobalKey _canvasKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TemplateEditorProvider>()
          .startEditing(widget.initialTemplate);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEditorProvider>(
      builder: (context, provider, child) {
        final template = provider.currentTemplate;

        if (template == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kDefaultColor),
            ),
          );
        }

        return Column(
          children: [
            // Enhanced Toolbar with app theme
            Container(
              decoration: BoxDecoration(
                color: kWhiteColor,
                boxShadow: [
                  BoxShadow(
                    color: kDefaultColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TemplateEditorToolbar(
                onExport: () => _exportTemplate(),
                onBackgroundColor: () => _showBackgroundColorPicker(),
                onBackgroundImage: () => _showBackgroundImagePicker(),
              ),
            ),

            // Enhanced Canvas Area with app theme
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kInputBoxBackGroundColor,
                      kBackGroundColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.3,
                      maxScale: 5.0,
                      child: GestureDetector(
                        onTap: () => provider.clearSelection(),
                        child: RepaintBoundary(
                          key: _canvasKey,
                          child: Container(
                            width: template.size.width,
                            height: template.size.height,
                            decoration: BoxDecoration(
                              color: _parseColor(template.backgroundColor),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: kDefaultColor.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: kDefaultColor.withOpacity(0.12),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Stack(
                                children: [
                                  // Background Layer
                                  if (template.backgroundImage.isNotEmpty)
                                    _buildBackgroundLayer(template),

                                  // Elements Layer
                                  ...template.elements.map((element) {
                                    return TemplateElementWidget(
                                      key: ValueKey(element.id),
                                      element: element,
                                      isSelected: provider.selectedElementId ==
                                          element.id,
                                      onTap: () =>
                                          _handleElementTap(element.id),
                                      onPositionChanged: (newPosition) =>
                                          provider.updateElementPosition(
                                              element.id, newPosition),
                                      onSizeChanged: (newSize) =>
                                          provider.updateElementSize(
                                              element.id, newSize),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundLayer(TemplateModel template) {
    return Positioned.fill(
      child: Image.file(
        File(template.backgroundImage),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: kInputBoxBackGroundColor,
            child: Center(
              child: Icon(
                Icons.broken_image,
                size: 50,
                color: kDarkGreyColor,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleElementTap(String elementId) {
    final provider = context.read<TemplateEditorProvider>();
    provider.selectElement(elementId);

    // Show text editing dialog for text elements
    final element = provider.getSelectedElement();
    if (element != null && element.type == ElementType.text) {
      _showTextEditDialog(element);
    }
  }

  void _showTextEditDialog(TemplateElementModel element) {
    final textController = TextEditingController(text: element.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kWhiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit Text',
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Enter text...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: null,
          style: TextStyle(color: kTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = context.read<TemplateEditorProvider>();
              provider.updateElementContent(element.id, textController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kDefaultColor,
              foregroundColor: kWhiteColor,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBackgroundColorPicker() {
    final provider = context.read<TemplateEditorProvider>();
    final template = provider.currentTemplate;

    if (template == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kWhiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Background Color',
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: 300,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              '#FFFFFF',
              '#F5F5F5',
              '#E3F2FD',
              '#FFF3E0',
              '#F3E5F5',
              '#E8F5E8',
              '#FFE0E0',
              '#000000',
              '#2196F3',
              '#4CAF50',
              '#FF9800',
              '#9C27B0',
              '#F44336',
              '#607D8B',
              '#795548',
              '#FF5722'
            ]
                .map((color) => GestureDetector(
                      onTap: () {
                        provider.updateCurrentTemplate(
                          template.copyWith(backgroundColor: color),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _parseColor(color),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: template.backgroundColor == color
                                ? kDefaultColor
                                : kDarkGreyColor.withOpacity(0.3),
                            width: template.backgroundColor == color ? 3 : 1,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBackgroundImagePicker() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final provider = context.read<TemplateEditorProvider>();
        final template = provider.currentTemplate;

        if (template != null) {
          provider.updateCurrentTemplate(
            template.copyWith(backgroundImage: image.path),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Background image updated!'),
              backgroundColor: kDefaultColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: kDefaultColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _exportTemplate() async {
    final provider = context.read<TemplateEditorProvider>();
    final template = provider.currentTemplate;

    if (template == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No template to export'),
          backgroundColor: kDefaultColor.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kWhiteColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kDefaultColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Exporting...',
              style: TextStyle(color: kTextColor),
            ),
          ],
        ),
      ),
    );

    try {
      final success = await TemplateExportUtil.exportTemplateAsImage(
        canvasKey: _canvasKey,
        template: template,
        context: context,
        filename: template.name.toLowerCase().replaceAll(' ', '_'),
      );

      Navigator.of(context).pop(); // Hide loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Template exported successfully!'),
            backgroundColor: kDefaultColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Hide loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: kDefaultColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(
          int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return kWhiteColor;
    }
  }

  GlobalKey get canvasKey => _canvasKey;
}
