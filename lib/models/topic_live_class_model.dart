class TopicLiveClassResponse {
  final bool success;
  final TopicInfo topic;
  final List<TopicLiveClass> liveMClass;

  TopicLiveClassResponse({
    required this.success,
    required this.topic,
    required this.liveMClass,
  });

  factory TopicLiveClassResponse.fromJson(Map<String, dynamic> json) {
    return TopicLiveClassResponse(
      success: json['success'] ?? false,
      topic: TopicInfo.fromJson(json['topic'] ?? {}),
      liveMClass: (json['live_m_class'] as List<dynamic>?)
              ?.map((item) => TopicLiveClass.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class TopicInfo {
  final int id;
  final String title;
  final String description;
  final String image;

  TopicInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory TopicInfo.fromJson(Map<String, dynamic> json) {
    return TopicInfo(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class TopicLiveClass {
  final int id;
  final int topicId;
  final String title;
  final String description;
  final String videoFile;
  final String thumbnail;
  final String startTime;
  final String endTime;
  final String date;
  final int isEnroll;
  final String formattedDateTime;
  final bool status;
  final TopicInfo topic;
  final String createdAt;
  final String updatedAt;

  TopicLiveClass({
    required this.id,
    required this.topicId,
    required this.title,
    required this.description,
    required this.videoFile,
    required this.thumbnail,
    required this.startTime,
    required this.endTime,
    required this.isEnroll,
    required this.date,
    required this.formattedDateTime,
    required this.status,
    required this.topic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TopicLiveClass.fromJson(Map<String, dynamic> json) {
    print('Parsing TopicLiveClass from JSON: $json');
    return TopicLiveClass(
      id: json['id'] ?? 0,
      topicId: json['topic_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isEnroll: json['is_enroll'] ?? 0,
      videoFile: json['video_file'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      date: json['date'] ?? '',
      formattedDateTime: json['formatted_date_time'] ?? '',
      status: json['status'] ?? false,
      topic: TopicInfo.fromJson(json['topic'] ?? {}),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Calculate countdown from start time
  Duration get timeUntilStart {
    try {
      final startDateTime = DateTime.parse(startTime);
      final now = DateTime.now();
      return startDateTime.difference(now);
    } catch (e) {
      return Duration.zero;
    }
  }

  // Get formatted countdown string
  String get countdownString {
    final duration = timeUntilStart;
    if (duration.isNegative) {
      return "Live Now";
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return "${days}d : ${hours}h : ${minutes}m";
    } else if (hours > 0) {
      return "${hours}h : ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }
}
