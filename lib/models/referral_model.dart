class ReferralUser {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String userID;
  final String referralCode;
  final String referralBy;
  final double walletBalance;
  final String? photo;
  final DateTime createdAt;
  final List<Subscription> subscriptions;
  final double commissionEarned;

  ReferralUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.userID,
    required this.referralCode,
    required this.referralBy,
    required this.walletBalance,
    this.photo,
    required this.createdAt,
    required this.subscriptions,
    required this.commissionEarned,
  });

  factory ReferralUser.fromJson(Map<String, dynamic> json) {
    return ReferralUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      userID: json['user_id'] ?? '',
      referralCode: json['referral_code'] ?? '',
      referralBy: json['referral_by'] ?? '',
      walletBalance: double.tryParse(json['wallet_balance'].toString()) ?? 0.0,
      photo: json['photo'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      subscriptions: (json['subscription'] as List<dynamic>?)
              ?.map((sub) => Subscription.fromJson(sub))
              .toList() ??
          [],
      commissionEarned: double.tryParse(json['comission_earn'].toString()) ?? 0.0,
    );
  }

  String get currentPlanName {
    if (subscriptions.isNotEmpty && subscriptions.first.plan != null) {
      return subscriptions.first.plan!.planName;
    }
    return 'No Plan';
  }

  String get profileImageUrl {
    if (photo != null && photo!.isNotEmpty) {
      // If photo starts with 'assets/', it's a relative path, prepend base URL
      if (photo!.startsWith('assets/')) {
        return 'https://nabyug.online/$photo';
      }
      return photo!;
    }
    return '';
  }
}

class Subscription {
  final int id;
  final int userId;
  final int planId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double amountPaid;
  final String paymentMethod;
  final String transactionId;
  final bool isUpgraded;
  final Plan? plan;

  Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.amountPaid,
    required this.paymentMethod,
    required this.transactionId,
    required this.isUpgraded,
    this.plan,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      planId: json['plan_id'] ?? 0,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
      amountPaid: double.tryParse(json['amount_paid'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      isUpgraded: json['is_upgraded'] ?? false,
      plan: json['plan'] != null ? Plan.fromJson(json['plan']) : null,
    );
  }
}

class Plan {
  final int id;
  final String planName;
  final String description;
  final int planPeriodDays;
  final int noOfCourses;
  final int noOfLiveClasses;
  final int noOfWebinars;
  final int noOfDiplomaCertificates;
  final double mrp;
  final double discountedPrice;

  Plan({
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
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? 0,
      planName: json['plan_name'] ?? '',
      description: json['description'] ?? '',
      planPeriodDays: json['plan_period_days'] ?? 0,
      noOfCourses: json['no_of_courses'] ?? 0,
      noOfLiveClasses: json['no_of_live_classes'] ?? 0,
      noOfWebinars: json['no_of_webinars'] ?? 0,
      noOfDiplomaCertificates: json['no_of_diploma_certificates'] ?? 0,
      mrp: double.tryParse(json['mrp'].toString()) ?? 0.0,
      discountedPrice: double.tryParse(json['discounted_price'].toString()) ?? 0.0,
    );
  }
}

class ReferralResponse {
  final bool success;
  final List<ReferralUser> data;

  ReferralResponse({
    required this.success,
    required this.data,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((user) => ReferralUser.fromJson(user))
              .toList() ??
          [],
    );
  }
}