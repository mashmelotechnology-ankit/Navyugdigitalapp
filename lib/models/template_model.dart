import 'dart:convert';

class TemplateModel {
  final String id;
  final String name;
  final String category;
  final String thumbnailPath;
  final String backgroundImage;
  final String backgroundColor;
  final List<TemplateElementModel> elements;
  final TemplateSize size;

  TemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.thumbnailPath,
    required this.backgroundImage,
    this.backgroundColor = '#FFFFFF',
    required this.elements,
    required this.size,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      thumbnailPath: json['thumbnailPath'],
      backgroundImage: json['backgroundImage'],
      backgroundColor: json['backgroundColor'] ?? '#FFFFFF',
      elements: (json['elements'] as List)
          .map((e) => TemplateElementModel.fromJson(e))
          .toList(),
      size: TemplateSize.fromJson(json['size']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'thumbnailPath': thumbnailPath,
      'backgroundImage': backgroundImage,
      'backgroundColor': backgroundColor,
      'elements': elements.map((e) => e.toJson()).toList(),
      'size': size.toJson(),
    };
  }

  TemplateModel copyWith({
    String? id,
    String? name,
    String? category,
    String? thumbnailPath,
    String? backgroundImage,
    String? backgroundColor,
    List<TemplateElementModel>? elements,
    TemplateSize? size,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elements: elements ?? this.elements,
      size: size ?? this.size,
    );
  }
}

class TemplateElementModel {
  final String id;
  final ElementType type;
  final String content;
  final ElementPosition position;
  final ElementSize size;
  final ElementStyle style;
  final bool isLocked;
  final bool isVisible;

  TemplateElementModel({
    required this.id,
    required this.type,
    required this.content,
    required this.position,
    required this.size,
    required this.style,
    this.isLocked = false,
    this.isVisible = true,
  });

  factory TemplateElementModel.fromJson(Map<String, dynamic> json) {
    return TemplateElementModel(
      id: json['id'],
      type: ElementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      content: json['content'],
      position: ElementPosition.fromJson(json['position']),
      size: ElementSize.fromJson(json['size']),
      style: ElementStyle.fromJson(json['style']),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'content': content,
      'position': position.toJson(),
      'size': size.toJson(),
      'style': style.toJson(),
      'isLocked': isLocked,
      'isVisible': isVisible,
    };
  }

  TemplateElementModel copyWith({
    String? id,
    ElementType? type,
    String? content,
    ElementPosition? position,
    ElementSize? size,
    ElementStyle? style,
    bool? isLocked,
    bool? isVisible,
  }) {
    return TemplateElementModel(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      position: position ?? this.position,
      size: size ?? this.size,
      style: style ?? this.style,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class ElementPosition {
  final double x;
  final double y;

  ElementPosition({required this.x, required this.y});

  factory ElementPosition.fromJson(Map<String, dynamic> json) {
    return ElementPosition(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }

  ElementPosition copyWith({double? x, double? y}) {
    return ElementPosition(x: x ?? this.x, y: y ?? this.y);
  }
}

class ElementSize {
  final double width;
  final double height;

  ElementSize({required this.width, required this.height});

  factory ElementSize.fromJson(Map<String, dynamic> json) {
    return ElementSize(
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'width': width, 'height': height};
  }

  ElementSize copyWith({double? width, double? height}) {
    return ElementSize(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

class ElementStyle {
  final String fontFamily;
  final double fontSize;
  final String color;
  final bool isBold;
  final bool isItalic;
  final bool isUnderlined;
  final String textAlign;
  final double rotation;
  final double opacity;
  final double borderRadius;
  final double borderWidth;
  final String borderColor;

  ElementStyle({
    this.fontFamily = 'Poppins',
    this.fontSize = 16.0,
    this.color = '#000000',
    this.isBold = false,
    this.isItalic = false,
    this.isUnderlined = false,
    this.textAlign = 'left',
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.borderRadius = 0.0,
    this.borderWidth = 0.0,
    this.borderColor = '#000000',
  });

  factory ElementStyle.fromJson(Map<String, dynamic> json) {
    return ElementStyle(
      fontFamily: json['fontFamily'] ?? 'Poppins',
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
      color: json['color'] ?? '#000000',
      isBold: json['isBold'] ?? false,
      isItalic: json['isItalic'] ?? false,
      isUnderlined: json['isUnderlined'] ?? false,
      textAlign: json['textAlign'] ?? 'left',
      rotation: json['rotation']?.toDouble() ?? 0.0,
      opacity: json['opacity']?.toDouble() ?? 1.0,
      borderRadius: json['borderRadius']?.toDouble() ?? 0.0,
      borderWidth: json['borderWidth']?.toDouble() ?? 0.0,
      borderColor: json['borderColor'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'color': color,
      'isBold': isBold,
      'isItalic': isItalic,
      'isUnderlined': isUnderlined,
      'textAlign': textAlign,
      'rotation': rotation,
      'opacity': opacity,
      'borderRadius': borderRadius,
      'borderWidth': borderWidth,
      'borderColor': borderColor,
    };
  }

  ElementStyle copyWith({
    String? fontFamily,
    double? fontSize,
    String? color,
    bool? isBold,
    bool? isItalic,
    bool? isUnderlined,
    String? textAlign,
    double? rotation,
    double? opacity,
    double? borderRadius,
    double? borderWidth,
    String? borderColor,
  }) {
    return ElementStyle(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderlined: isUnderlined ?? this.isUnderlined,
      textAlign: textAlign ?? this.textAlign,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}

class TemplateSize {
  final double width;
  final double height;

  TemplateSize({required this.width, required this.height});

  factory TemplateSize.fromJson(Map<String, dynamic> json) {
    return TemplateSize(
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'width': width, 'height': height};
  }
}

enum ElementType {
  text,
  image,
  shape,
}