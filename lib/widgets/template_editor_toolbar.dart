import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/template_editor_provider.dart';
import '../models/template_model.dart';

class TemplateEditorToolbar extends StatelessWidget {
  final VoidCallback? onExport;
  final VoidCallback? onBackgroundColor;
  final VoidCallback? onBackgroundImage;

  const TemplateEditorToolbar({
    Key? key,
    this.onExport,
    this.onBackgroundColor,
    this.onBackgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEditorProvider>(
      builder: (context, provider, child) {
        final selectedElement = provider.getSelectedElement();

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: kWhiteColor,
            border: Border(
              bottom:
                  BorderSide(color: kDefaultColor.withOpacity(0.15), width: 1),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Add Text Button
                _buildToolButton(
                  icon: Icons.text_fields,
                  label: 'Text',
                  onPressed: () => provider.addTextElement(),
                ),

                const SizedBox(width: 8),

                // Add Shape Button
                _buildToolButton(
                  icon: Icons.crop_square,
                  label: 'Shape',
                  onPressed: () => _showShapeOptions(context, provider),
                ),

                const SizedBox(width: 8),

                // Add Image Button
                _buildToolButton(
                  icon: Icons.image,
                  label: 'Image',
                  onPressed: () => _addImageElement(provider),
                ),

                const SizedBox(width: 16),

                // Divider
                Container(
                  width: 1,
                  height: 30,
                  color: kDarkGreyColor.withOpacity(0.3),
                ),

                const SizedBox(width: 16),

                // Delete Button (only show if element is selected)
                if (selectedElement != null) ...[
                  _buildToolButton(
                    icon: Icons.delete,
                    label: 'Delete',
                    color: kDefaultColor,
                    onPressed: () => provider.deleteElement(selectedElement.id),
                  ),
                  const SizedBox(width: 8),
                ],

                // Layer controls
                if (selectedElement != null) ...[
                  _buildToolButton(
                    icon: Icons.keyboard_arrow_up,
                    label: 'Front',
                    onPressed: () => _moveToFront(provider, selectedElement.id),
                  ),

                  const SizedBox(width: 8),

                  _buildToolButton(
                    icon: Icons.keyboard_arrow_down,
                    label: 'Back',
                    onPressed: () => _moveToBack(provider, selectedElement.id),
                  ),

                  const SizedBox(width: 16),

                  // Divider
                  Container(
                    width: 1,
                    height: 30,
                    color: kDarkGreyColor.withOpacity(0.3),
                  ),

                  const SizedBox(width: 16),
                ],

                // Background Color Button
                if (onBackgroundColor != null) ...[
                  _buildToolButton(
                    icon: Icons.palette,
                    label: 'BG Color',
                    color: kDefaultColor,
                    onPressed: onBackgroundColor!,
                  ),
                  const SizedBox(width: 8),
                ],

                // Background Image Button
                if (onBackgroundImage != null) ...[
                  _buildToolButton(
                    icon: Icons.wallpaper,
                    label: 'BG Image',
                    color: kDefaultColor,
                    onPressed: onBackgroundImage!,
                  ),
                  const SizedBox(width: 8),
                ],

                // Export Button
                if (onExport != null)
                  _buildToolButton(
                    icon: Icons.download,
                    label: 'Export',
                    color: kDefaultColor,
                    onPressed: onExport!,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color ?? kDarkGreyColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color ?? kTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? kTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShapeOptions(
      BuildContext context, TemplateEditorProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shape'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.crop_square),
              title: const Text('Rectangle'),
              onTap: () {
                _addShapeElement(provider, 'rectangle');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle_outlined),
              title: const Text('Circle'),
              onTap: () {
                _addShapeElement(provider, 'circle');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addShapeElement(TemplateEditorProvider provider, String shapeType) {
    final newElement = TemplateElementModel(
      id: 'shape_${DateTime.now().millisecondsSinceEpoch}',
      type: ElementType.shape,
      content: shapeType,
      position: ElementPosition(x: 50, y: 100),
      size: ElementSize(width: 100, height: 100),
      style: ElementStyle(
        color: '#FF5722',
        borderRadius: shapeType == 'circle' ? 50 : 8,
      ),
    );

    if (provider.currentTemplate != null) {
      final updatedElements = [
        ...provider.currentTemplate!.elements,
        newElement
      ];
      provider.updateCurrentTemplate(
        provider.currentTemplate!.copyWith(elements: updatedElements),
      );
      provider.selectElement(newElement.id);
    }
  }

  void _addImageElement(TemplateEditorProvider provider) {
    final newElement = TemplateElementModel(
      id: 'image_${DateTime.now().millisecondsSinceEpoch}',
      type: ElementType.image,
      content: '', // Will be set when user selects an image
      position: ElementPosition(x: 50, y: 100),
      size: ElementSize(width: 150, height: 150),
      style: ElementStyle(),
    );

    if (provider.currentTemplate != null) {
      final updatedElements = [
        ...provider.currentTemplate!.elements,
        newElement
      ];
      provider.updateCurrentTemplate(
        provider.currentTemplate!.copyWith(elements: updatedElements),
      );
      provider.selectElement(newElement.id);
    }
  }

  void _moveToFront(TemplateEditorProvider provider, String elementId) {
    if (provider.currentTemplate == null) return;

    final elements =
        List<TemplateElementModel>.from(provider.currentTemplate!.elements);
    final elementIndex = elements.indexWhere((e) => e.id == elementId);

    if (elementIndex != -1 && elementIndex < elements.length - 1) {
      final element = elements.removeAt(elementIndex);
      elements.add(element);

      provider.updateCurrentTemplate(
        provider.currentTemplate!.copyWith(elements: elements),
      );
    }
  }

  void _moveToBack(TemplateEditorProvider provider, String elementId) {
    if (provider.currentTemplate == null) return;

    final elements =
        List<TemplateElementModel>.from(provider.currentTemplate!.elements);
    final elementIndex = elements.indexWhere((e) => e.id == elementId);

    if (elementIndex > 0) {
      final element = elements.removeAt(elementIndex);
      elements.insert(0, element);

      provider.updateCurrentTemplate(
        provider.currentTemplate!.copyWith(elements: elements),
      );
    }
  }
}
