import 'dart:convert';

class SubscriptionPlan {
  final int? id;
  final String? planName;
  final String? description;
  final int? planPeriodDays;
  final int? noOfCourses;
  final int? noOfLiveClasses;
  final int? noOfWebinars;
  final int? noOfDiplomaCertificates;
  final double? mrp;
  final double? discountedPrice;
  final double? savings;
  final double? discountPercentage;
  final List<String>? features;
  final String? createdAt;
  final String? updatedAt;

  SubscriptionPlan({
    this.id,
    this.planName,
    this.description,
    this.planPeriodDays,
    this.noOfCourses,
    this.noOfLiveClasses,
    this.noOfWebinars,
    this.noOfDiplomaCertificates,
    this.mrp,
    this.discountedPrice,
    this.savings,
    this.discountPercentage,
    this.features,
    this.createdAt,
    this.updatedAt,
  });

  static List<String>? _parseFeatures(dynamic features) {
    if (features == null) return null;

    // If it's already a List, convert to List<String>
    if (features is List) {
      return List<String>.from(features.map((x) => x.toString()));
    }

    // If it's a String (JSON string), parse it first
    if (features is String) {
      try {
        final decoded = json.decode(features);
        if (decoded is List) {
          return List<String>.from(decoded.map((x) => x.toString()));
        }
      } catch (e) {
        print('Error parsing features string: $e');
        return null;
      }
    }

    return null;
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      planName: json['plan_name'],
      description: json['description'],
      planPeriodDays: json['plan_period_days'],
      noOfCourses: json['no_of_courses'],
      noOfLiveClasses: json['no_of_live_classes'],
      noOfWebinars: json['no_of_webinars'],
      noOfDiplomaCertificates: json['no_of_diploma_certificates'],
      mrp: json['mrp'] != null ? double.parse(json['mrp'].toString()) : null,
      discountedPrice: json['discounted_price'] != null
          ? double.parse(json['discounted_price'].toString())
          : null,
      savings: json['savings'] != null
          ? double.parse(json['savings'].toString())
          : null,
      discountPercentage: json['discount_percentage'] != null
          ? double.parse(json['discount_percentage'].toString())
          : null,
      features:
          json['features'] != null ? _parseFeatures(json['features']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'description': description,
      'plan_period_days': planPeriodDays,
      'no_of_courses': noOfCourses,
      'no_of_live_classes': noOfLiveClasses,
      'no_of_webinars': noOfWebinars,
      'no_of_diploma_certificates': noOfDiplomaCertificates,
      'mrp': mrp,
      'discounted_price': discountedPrice,
      'savings': savings,
      'discount_percentage': discountPercentage,
      'features': features,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
