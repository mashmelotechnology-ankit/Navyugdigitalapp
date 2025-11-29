import 'package:flutter/material.dart';
import '../models/template_model.dart';
import '../constants.dart';

class TemplateElementWidget extends StatefulWidget {
  final TemplateElementModel element;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(ElementPosition) onPositionChanged;
  final Function(ElementSize) onSizeChanged;

  const TemplateElementWidget({
    Key? key,
    required this.element,
    required this.isSelected,
    required this.onTap,
    required this.onPositionChanged,
    required this.onSizeChanged,
  }) : super(key: key);

  @override
  State<TemplateElementWidget> createState() => _TemplateElementWidgetState();
}

class _TemplateElementWidgetState extends State<TemplateElementWidget> {
  late double _currentX;
  late double _currentY;
  late double _currentWidth;
  late double _currentHeight;

  @override
  void initState() {
    super.initState();
    _currentX = widget.element.position.x;
    _currentY = widget.element.position.y;
    _currentWidth = widget.element.size.width;
    _currentHeight = widget.element.size.height;
  }

  @override
  void didUpdateWidget(TemplateElementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element.position != widget.element.position) {
      _currentX = widget.element.position.x;
      _currentY = widget.element.position.y;
    }
    if (oldWidget.element.size != widget.element.size) {
      _currentWidth = widget.element.size.width;
      _currentHeight = widget.element.size.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _currentX,
      top: _currentY,
      child: GestureDetector(
        onTap: () {
          widget.onTap();
        },
        onPanUpdate: (details) {
          setState(() {
            _currentX += details.delta.dx;
            _currentY += details.delta.dy;

            // Prevent dragging outside canvas bounds
            _currentX = _currentX.clamp(0.0, double.infinity);
            _currentY = _currentY.clamp(0.0, double.infinity);
          });
        },
        onPanEnd: (details) {
          widget.onPositionChanged(ElementPosition(x: _currentX, y: _currentY));
        },
        child: Container(
          width: _currentWidth,
          height: _currentHeight,
          decoration: widget.isSelected
              ? BoxDecoration(
                  border: Border.all(
                    color: kDefaultColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Stack(
            children: [
              // Element content
              _buildElementContent(),

              // Selection handles
              if (widget.isSelected) ..._buildSelectionHandles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElementContent() {
    switch (widget.element.type) {
      case ElementType.text:
        return _buildTextElement();
      case ElementType.image:
        return _buildImageElement();
      case ElementType.shape:
        return _buildShapeElement();
    }
  }

  Widget _buildTextElement() {
    final style = widget.element.style;

    return Container(
      width: _currentWidth,
      height: _currentHeight,
      padding: const EdgeInsets.all(4),
      child: Text(
        widget.element.content,
        style: TextStyle(
          fontSize: style.fontSize,
          fontWeight: style.isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: style.isItalic ? FontStyle.italic : FontStyle.normal,
          color: _parseColor(style.color),
          fontFamily: style.fontFamily,
        ),
        textAlign: _parseTextAlign(style.textAlign),
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildImageElement() {
    return Container(
      width: _currentWidth,
      height: _currentHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: widget.element.content.isNotEmpty
            ? Image.asset(
                widget.element.content,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.add_photo_alternate,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }

  Widget _buildShapeElement() {
    final style = widget.element.style;
    final color = _parseColor(style.color);

    return Container(
      width: _currentWidth,
      height: _currentHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(style.borderRadius),
        border: style.borderWidth > 0
            ? Border.all(
                color: _parseColor(style.borderColor),
                width: style.borderWidth,
              )
            : null,
      ),
    );
  }

  List<Widget> _buildSelectionHandles() {
    const handleSize = 12.0;
    const handleColor = kDefaultColor;

    return [
      // Top-left
      Positioned(
        left: -handleSize / 2,
        top: -handleSize / 2,
        child: _buildResizeHandle(
          handleColor,
          handleSize,
          onDrag: (delta) => _resizeFromTopLeft(delta),
        ),
      ),
      // Top-right
      Positioned(
        right: -handleSize / 2,
        top: -handleSize / 2,
        child: _buildResizeHandle(
          handleColor,
          handleSize,
          onDrag: (delta) => _resizeFromTopRight(delta),
        ),
      ),
      // Bottom-left
      Positioned(
        left: -handleSize / 2,
        bottom: -handleSize / 2,
        child: _buildResizeHandle(
          handleColor,
          handleSize,
          onDrag: (delta) => _resizeFromBottomLeft(delta),
        ),
      ),
      // Bottom-right
      Positioned(
        right: -handleSize / 2,
        bottom: -handleSize / 2,
        child: _buildResizeHandle(
          handleColor,
          handleSize,
          onDrag: (delta) => _resizeFromBottomRight(delta),
        ),
      ),
    ];
  }

  Widget _buildResizeHandle(Color color, double size,
      {required Function(Offset) onDrag}) {
    return GestureDetector(
      onPanUpdate: (details) => onDrag(details.delta),
      onPanEnd: (details) {
        widget.onSizeChanged(
            ElementSize(width: _currentWidth, height: _currentHeight));
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  void _resizeFromTopLeft(Offset delta) {
    setState(() {
      final newWidth = _currentWidth - delta.dx;
      final newHeight = _currentHeight - delta.dy;

      if (newWidth > 20 && newHeight > 20) {
        _currentX += delta.dx;
        _currentY += delta.dy;
        _currentWidth = newWidth;
        _currentHeight = newHeight;
      }
    });
  }

  void _resizeFromTopRight(Offset delta) {
    setState(() {
      final newWidth = _currentWidth + delta.dx;
      final newHeight = _currentHeight - delta.dy;

      if (newWidth > 20 && newHeight > 20) {
        _currentY += delta.dy;
        _currentWidth = newWidth;
        _currentHeight = newHeight;
      }
    });
  }

  void _resizeFromBottomLeft(Offset delta) {
    setState(() {
      final newWidth = _currentWidth - delta.dx;
      final newHeight = _currentHeight + delta.dy;

      if (newWidth > 20 && newHeight > 20) {
        _currentX += delta.dx;
        _currentWidth = newWidth;
        _currentHeight = newHeight;
      }
    });
  }

  void _resizeFromBottomRight(Offset delta) {
    setState(() {
      final newWidth = _currentWidth + delta.dx;
      final newHeight = _currentHeight + delta.dy;

      if (newWidth > 20 && newHeight > 20) {
        _currentWidth = newWidth;
        _currentHeight = newHeight;
      }
    });
  }

  Color _parseColor(String colorString) {
    try {
      return Color(
          int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.black;
    }
  }

  TextAlign _parseTextAlign(String? textAlign) {
    switch (textAlign) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }
}
