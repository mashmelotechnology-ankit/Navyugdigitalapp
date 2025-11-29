class UserData {
  final bool success;
  final UserDataInfo data;
  final String message;

  UserData({
    required this.success,
    required this.data,
    required this.message,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      success: json['success'] ?? false,
      data: UserDataInfo.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class UserDataInfo {
  final int id;
  final String role;
  final String email;
  final int status;
  final String name;
  final String? fatherHusbandName;
  final String phone;
  final String? website;
  final String? skills;
  final String? facebook;
  final String? twitter;
  final String? linkedin;
  final String? address;
  final String? about;
  final String? biography;
  final String? educations;
  final String? photo;
  final String? emailVerifiedAt;
  final String? paymentkeys;
  final String? videoUrl;
  final String userId;
  final String? salonName;
  final String? referralCode;
  final String? referralBy;
  final double walletBalance;
  final int noOfCourse;
  final int noOfLiveClasses;
  final int noOfWebinars;
  final int noOfDiplomaCertificates;
  final int isExisting;
  final int takeCharge;
  final String amount;
  final String createdAt;
  final String updatedAt;

  UserDataInfo({
    required this.id,
    required this.role,
    required this.email,
    required this.status,
    required this.name,
    this.fatherHusbandName,
    required this.phone,
    this.website,
    this.skills,
    this.facebook,
    this.twitter,
    this.linkedin,
    this.address,
    this.about,
    this.biography,
    this.educations,
    this.photo,
    this.emailVerifiedAt,
    this.paymentkeys,
    this.videoUrl,
    required this.userId,
    this.salonName,
    this.referralCode,
    this.referralBy,
    required this.walletBalance,
    required this.noOfCourse,
    required this.noOfLiveClasses,
    required this.noOfWebinars,
    required this.noOfDiplomaCertificates,
    required this.isExisting,
    required this.takeCharge,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDataInfo.fromJson(Map<String, dynamic> json) {
    return UserDataInfo(
      id: json['id'] ?? 0,
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 0,
      name: json['name'] ?? '',
      fatherHusbandName: json['father_husband_name'],
      phone: json['phone'] ?? '',
      website: json['website'],
      skills: json['skills'],
      facebook: json['facebook'],
      twitter: json['twitter'],
      linkedin: json['linkedin'],
      address: json['address'],
      about: json['about'],
      biography: json['biography'],
      educations: json['educations'],
      photo: json['photo'],
      emailVerifiedAt: json['email_verified_at'],
      paymentkeys: json['paymentkeys'],
      videoUrl: json['video_url'],
      userId: json['user_id'] ?? '',
      salonName: json['salon_name'],
      referralCode: json['referral_code'],
      referralBy: json['referral_by'],
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      noOfCourse: json['no_of_course'] ?? 0,
      noOfLiveClasses: json['no_of_live_classes'] ?? 0,
      noOfWebinars: json['no_of_webinars'] ?? 0,
      noOfDiplomaCertificates: json['no_of_diploma_certificates'] ?? 0,
      isExisting: json['is_existing'] ?? 0,
      takeCharge: json['take_charge'] ?? 0,
      amount: json['amount']?.toString() ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
