// Certificate Template Model based on new API response
class CertificateTemplate {
  final int id;
  final String name;
  final String description;
  final String templateImage;
  final String builderContent;
  final bool isActive;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;

  CertificateTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.templateImage,
    required this.builderContent,
    required this.isActive,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CertificateTemplate.fromJson(Map<String, dynamic> json) {
    return CertificateTemplate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      templateImage: json['template_image'] ?? '',
      builderContent: json['builder_content'] ?? '',
      isActive: json['is_active'] ?? false,
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'template_image': templateImage,
      'builder_content': builderContent,
      'is_active': isActive,
      'is_default': isDefault,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Syllabus Model
class SyllabusModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final bool status;
  final String createdAt;
  final String updatedAt;

  SyllabusModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    return SyllabusModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Legacy Certificate Template Model (keeping for backward compatibility)
class CertificateTemplateModel {
  final String templateOne;
  final String templateTwo;
  final String templateThree;
  final String templateFour;
  final String templateFive;
  final String templateSix;
  final String templateSeven;
  final String templateEight;
  final String templateNine;
  final String templateTen;

  CertificateTemplateModel({
    required this.templateOne,
    required this.templateTwo,
    required this.templateThree,
    required this.templateFour,
    required this.templateFive,
    required this.templateSix,
    required this.templateSeven,
    required this.templateEight,
    required this.templateNine,
    required this.templateTen,
  });

  factory CertificateTemplateModel.fromJson(Map<String, dynamic> json) {
    return CertificateTemplateModel(
      templateOne: json['template_one'] ?? '',
      templateTwo: json['template_two'] ?? '',
      templateThree: json['template_three'] ?? '',
      templateFour: json['template_four'] ?? '',
      templateFive: json['template_five'] ?? '',
      templateSix: json['template_six'] ?? '',
      templateSeven: json['template_seven'] ?? '',
      templateEight: json['template_eight'] ?? '',
      templateNine: json['template_nine'] ?? '',
      templateTen: json['template_ten'] ?? '',
    );
  }

  List<String> get allTemplates => [
        templateOne,
        templateTwo,
        templateThree,
        templateFour,
        templateFive,
        templateSix,
        templateSeven,
        templateEight,
        templateNine,
        templateTen,
      ];

  String getTemplateByIndex(int index) {
    final templates = allTemplates;
    if (index >= 0 && index < templates.length) {
      return templates[index];
    }
    return templateOne; // Default to first template
  }
}

class CertificateCourseModel {
  final int id;
  final String title;
  final String slug;
  final String shortDescription;
  final int userId;
  final int categoryId;
  final String courseType;
  final String status;
  final String level;
  final String language;
  final int isPaid;
  final int isBest;
  final String price;
  final String? discountedPrice;
  final String? discountFlag;
  final int enableDripContent;
  final String dripContentSettings;
  final String metaKeywords;
  final String? metaDescription;
  final String thumbnail;
  final String banner;
  final String preview;
  final String description;
  final List<dynamic> requirements;
  final List<dynamic> outcomes;
  final List<dynamic> faqs;
  final String instructorIds;
  final String averageRating;
  final String createdAt;
  final String updatedAt;
  final String? expiryPeriod;
  final List<String> instructors;
  final String instructorName;
  final String instructorImage;
  final int totalEnrollment;
  final String shareableLink;
  final int totalReviews;
  final int completion;
  final int totalNumberOfLessons;
  final int totalNumberOfCompletedLessons;

  CertificateCourseModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.userId,
    required this.categoryId,
    required this.courseType,
    required this.status,
    required this.level,
    required this.language,
    required this.isPaid,
    required this.isBest,
    required this.price,
    this.discountedPrice,
    this.discountFlag,
    required this.enableDripContent,
    required this.dripContentSettings,
    required this.metaKeywords,
    this.metaDescription,
    required this.thumbnail,
    required this.banner,
    required this.preview,
    required this.description,
    required this.requirements,
    required this.outcomes,
    required this.faqs,
    required this.instructorIds,
    required this.averageRating,
    required this.createdAt,
    required this.updatedAt,
    this.expiryPeriod,
    required this.instructors,
    required this.instructorName,
    required this.instructorImage,
    required this.totalEnrollment,
    required this.shareableLink,
    required this.totalReviews,
    required this.completion,
    required this.totalNumberOfLessons,
    required this.totalNumberOfCompletedLessons,
  });

  factory CertificateCourseModel.fromJson(Map<String, dynamic> json) {
    return CertificateCourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      shortDescription: json['short_description'] ?? '',
      userId: json['user_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      courseType: json['course_type'] ?? '',
      status: json['status'] ?? '',
      level: json['level'] ?? '',
      language: json['language'] ?? '',
      isPaid: json['is_paid'] ?? 0,
      isBest: json['is_best'] ?? 0,
      price: json['price'] ?? '',
      discountedPrice: json['discounted_price'],
      discountFlag: json['discount_flag'],
      enableDripContent: json['enable_drip_content'] ?? 0,
      dripContentSettings: json['drip_content_settings'] ?? '',
      metaKeywords: json['meta_keywords'] ?? '',
      metaDescription: json['meta_description'],
      thumbnail: json['thumbnail'] ?? '',
      banner: json['banner'] ?? '',
      preview: json['preview'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? [],
      outcomes: json['outcomes'] ?? [],
      faqs: json['faqs'] ?? [],
      instructorIds: json['instructor_ids'] ?? '',
      averageRating: json['average_rating'] ?? '0.0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      expiryPeriod: json['expiry_period'],
      instructors: List<String>.from(json['instructors'] ?? []),
      instructorName: json['instructor_name'] ?? '',
      instructorImage: json['instructor_image'] ?? '',
      totalEnrollment: json['total_enrollment'] ?? 0,
      shareableLink: json['shareable_link'] ?? '',
      totalReviews: json['total_reviews'] ?? 0,
      completion: json['completion'] ?? 0,
      totalNumberOfLessons: json['total_number_of_lessons'] ?? 0,
      totalNumberOfCompletedLessons:
          json['total_number_of_completed_lessons'] ?? 0,
    );
  }

  bool get isCompleted => completion >= 100;

  String get formattedLevel {
    return level.replaceFirst(level[0], level[0].toUpperCase());
  }

  String get formattedLanguage {
    return language.replaceFirst(language[0], language[0].toUpperCase());
  }
}

// Updated Certificate Response Model for new API structure
class CertificateResponseModel {
  final List<CertificateTemplate> certificates;
  final List<SyllabusModel> syllabus;
  final String message;
  final int status;

  CertificateResponseModel({
    required this.certificates,
    required this.syllabus,
    required this.message,
    required this.status,
  });

  factory CertificateResponseModel.fromJson(Map<String, dynamic> json) {
    return CertificateResponseModel(
      certificates: (json['certificate'] as List<dynamic>?)
              ?.map((item) =>
                  CertificateTemplate.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      syllabus: (json['syllabus'] as List<dynamic>?)
              ?.map((item) =>
                  SyllabusModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificate': certificates.map((cert) => cert.toJson()).toList(),
      'syllabus': syllabus.map((syl) => syl.toJson()).toList(),
      'message': message,
      'status': status,
    };
  }

  // Helper methods for easier access
  List<CertificateTemplate> get activeCertificates =>
      certificates.where((cert) => cert.isActive).toList();

  CertificateTemplate? get defaultCertificate => certificates.isNotEmpty
      ? certificates.firstWhere(
          (cert) => cert.isDefault,
          orElse: () => certificates.first,
        )
      : null;

  List<SyllabusModel> get activeSyllabus =>
      syllabus.where((syl) => syl.status).toList();
}

// Legacy Certificate Response Model (keeping for backward compatibility)
class LegacyCertificateResponseModel {
  final bool success;
  final CertificateTemplateModel certificate;
  final List<CertificateCourseModel> courses;

  LegacyCertificateResponseModel({
    required this.success,
    required this.certificate,
    required this.courses,
  });

  factory LegacyCertificateResponseModel.fromJson(Map<String, dynamic> json) {
    return LegacyCertificateResponseModel(
      success: json['success'] ?? false,
      certificate: CertificateTemplateModel.fromJson(json['certificate'] ?? {}),
      courses: (json['courses'] as List<dynamic>?)
              ?.map((course) => CertificateCourseModel.fromJson(course))
              .toList() ??
          [],
    );
  }

  List<CertificateCourseModel> get completedCourses =>
      courses.where((course) => course.isCompleted).toList();
}

class CertificateGenerateRequestModel {
  final int templateId;
  final int syllabusId;
  final String courseDuration;
  final String studentName;
  final String fatherName;
  final String mobileNumber;
  final String syllabusTitle;
  final String courseCompletionDate;
  final String certificateDownloadDate;
  final String courseLevel;
  final dynamic studentPhoto; // Can be File or null

  CertificateGenerateRequestModel({
    required this.templateId,
    required this.syllabusId,
    required this.courseDuration,
    required this.mobileNumber,
    required this.studentName,
    required this.fatherName,
    required this.syllabusTitle,
    required this.courseCompletionDate,
    required this.certificateDownloadDate,
    required this.courseLevel,
    this.studentPhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'syllabus_id': syllabusId,
      'course_duration': courseDuration,
      'phone': mobileNumber,
      'student_name': studentName,
      'father_name': fatherName,
      'syllabus_title': syllabusTitle,
      'course_completion_date': courseCompletionDate,
      'certificate_download_date': certificateDownloadDate,
      'course_level': courseLevel,
      'photo': studentPhoto,
      // Note: studentPhoto will be handled separately for file upload
    };
  }
}
