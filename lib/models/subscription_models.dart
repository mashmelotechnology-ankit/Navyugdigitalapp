import 'subscription_plan.dart';

class CurrentSubscription {
  final int? id;
  final SubscriptionPlan? plan;
  final String? startDate;
  final String? endDate;
  final double? remainingDays;
  final String? status;
  final double? amountPaid;
  final bool? isActive;
  final bool? isUpgraded;

  CurrentSubscription({
    this.id,
    this.plan,
    this.startDate,
    this.endDate,
    this.remainingDays,
    this.status,
    this.amountPaid,
    this.isActive,
    this.isUpgraded,
  });

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    print(json);
    return CurrentSubscription(
      id: json['id'],
      plan:
          json['plan'] != null ? SubscriptionPlan.fromJson(json['plan']) : null,
      startDate: json['start_date'],
      endDate: json['end_date'],
      remainingDays: json['remaining_days'] != null
          ? double.parse(json['remaining_days'].toString())
          : null,
      status: json['status'],
      amountPaid: json['amount_paid'] != null
          ? double.parse(json['amount_paid'].toString())
          : null,
      isActive: json['is_active'],
      isUpgraded: json['is_upgraded'],
    );
  }
}

class UpgradeCost {
  final double? upgradeCost;
  final bool? isUpgrade;
  final SubscriptionPlan? currentPlan;
  final SubscriptionPlan? newPlan;
  final double? remainingDays;
  final double? currentPlanDailyRate;
  final double? refundAmount;

  UpgradeCost({
    this.upgradeCost,
    this.isUpgrade,
    this.currentPlan,
    this.newPlan,
    this.remainingDays,
    this.currentPlanDailyRate,
    this.refundAmount,
  });

  factory UpgradeCost.fromJson(Map<String, dynamic> json) {
    print("current plan:${json['current_plan']}");
    print("New Plan: ${json['new_plan']}");
    return UpgradeCost(
      upgradeCost: json['upgrade_cost'] != null
          ? double.parse(json['upgrade_cost'].toString())
          : null,
      isUpgrade: json['is_upgrade'],
      currentPlan: json['current_plan'] != null
          ? SubscriptionPlan.fromJson(json['current_plan'])
          : null,
      newPlan: json['new_plan'] != null
          ? SubscriptionPlan.fromJson(json['new_plan'])
          : null,
      remainingDays: json['remaining_days'] != null
          ? double.parse(json['remaining_days'].toString())
          : null,
      currentPlanDailyRate: json['current_plan_daily_rate'] != null
          ? double.parse(json['current_plan_daily_rate'].toString())
          : null,
      refundAmount: json['refund_amount'] != null
          ? double.parse(json['refund_amount'].toString())
          : null,
    );
  }
}

class SubscriptionHistory {
  final int? id;
  final SubscriptionPlan? plan;
  final String? startDate;
  final String? endDate;
  final String? status;
  final double? amountPaid;
  final String? paymentMethod;
  final bool? isUpgraded;
  final String? createdAt;

  SubscriptionHistory({
    this.id,
    this.plan,
    this.startDate,
    this.endDate,
    this.status,
    this.amountPaid,
    this.paymentMethod,
    this.isUpgraded,
    this.createdAt,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'],
      plan:
          json['plan'] != null ? SubscriptionPlan.fromJson(json['plan']) : null,
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      amountPaid: json['amount_paid'] != null
          ? double.parse(json['amount_paid'].toString())
          : null,
      paymentMethod: json['payment_method'],
      isUpgraded: json['is_upgraded'],
      createdAt: json['created_at'],
    );
  }
}
