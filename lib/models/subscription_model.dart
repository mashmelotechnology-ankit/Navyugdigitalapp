class SubscriptionData {
  final int id;
  final SubscriptionPlan plan;
  final String startDate;
  final String endDate;
  final double remainingDays;
  final String status;
  final String amountPaid;
  final bool isActive;
  final bool isUpgraded;

  SubscriptionData({
    required this.id,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.remainingDays,
    required this.status,
    required this.amountPaid,
    required this.isActive,
    required this.isUpgraded,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['id'] ?? 0,
      plan: SubscriptionPlan.fromJson(json['plan'] ?? {}),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      remainingDays: (json['remaining_days'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      amountPaid: json['amount_paid'] ?? '0',
      isActive: json['is_active'] ?? false,
      isUpgraded: json['is_upgraded'] ?? false,
    );
  }
}

class SubscriptionPlan {
  final int id;
  final String planName;
  final String description;
  final int planPeriodDays;
  final int noOfCourses;
  final int noOfLiveClasses;
  final int noOfWebinars;
  final int noOfDiplomaCertificates;
  final String mrp;
  final String discountedPrice;
  final String createdAt;
  final String updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.planName,
    required this.description,
    required this.planPeriodDays,
    required this.noOfCourses,
    required this.noOfLiveClasses,
    required this.noOfWebinars,
    required this.noOfDiplomaCertificates,
    required this.mrp,
    required this.discountedPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      planName: json['plan_name'] ?? '',
      description: json['description'] ?? '',
      planPeriodDays: json['plan_period_days'] ?? 0,
      noOfCourses: json['no_of_courses'] ?? 0,
      noOfLiveClasses: json['no_of_live_classes'] ?? 0,
      noOfWebinars: json['no_of_webinars'] ?? 0,
      noOfDiplomaCertificates: json['no_of_diploma_certificates'] ?? 0,
      mrp: json['mrp'] ?? '0',
      discountedPrice: json['discounted_price'] ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class CheckSubscriptionResponse {
  final bool success;
  final SubscriptionData? data;
  final String message;

  CheckSubscriptionResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory CheckSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return CheckSubscriptionResponse(
      success: json['success'] ?? false,
      data:
          json['data'] != null ? SubscriptionData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}
