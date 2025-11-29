class WebinarModel {
  final int id;
  final int topicId;
  final String title;
  final String description;
  final String videoFile;
  final String startTime;
  final String thumbnail;
  final String endTime;
  final String date;
  final bool status;
  final int isEnroll;
  final Topic topic;
  final String createdAt;
  final String updatedAt;

  WebinarModel({
    required this.id,
    required this.topicId,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoFile,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.status,
    required this.topic,
    required this.isEnroll,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WebinarModel.fromJson(Map<String, dynamic> json) {
    return WebinarModel(
      id: json['id'] ?? 0,
      topicId: json['topic_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      videoFile: json['video_file'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isEnroll: json['is_enroll'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? false,
      topic: json['topic'] != null
          ? Topic.fromJson(json['topic'])
          : Topic(id: 0, title: '', description: '', image: ''),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_id': topicId,
      'title': title,
      'description': description,
      'video_file': videoFile,
      'start_time': startTime,
      'thumbnail': thumbnail,
      'end_time': endTime,
      'date': date,
      'status': status,
      'topic': topic.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method to check if webinar is live (simplified since we don't have full datetime)
  bool get isLive {
    try {
      final now = DateTime.now();
      final webinarDate = DateTime.parse(date);

      // Check if the webinar is today
      if (webinarDate.year == now.year &&
          webinarDate.month == now.month &&
          webinarDate.day == now.day) {
        // Parse time (assuming format HH:mm)
        final startTimeParts = startTime.split(':');
        final endTimeParts = endTime.split(':');

        if (startTimeParts.length >= 2 && endTimeParts.length >= 2) {
          final startHour = int.parse(startTimeParts[0]);
          final startMinute = int.parse(startTimeParts[1]);
          final endHour = int.parse(endTimeParts[0]);
          final endMinute = int.parse(endTimeParts[1]);

          final startDateTime =
              DateTime(now.year, now.month, now.day, startHour, startMinute);
          final endDateTime =
              DateTime(now.year, now.month, now.day, endHour, endMinute);

          return now.isAfter(startDateTime) && now.isBefore(endDateTime);
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Helper method to check if webinar is upcoming
  bool get isUpcoming {
    try {
      final now = DateTime.now();
      final webinarDate = DateTime.parse(date);

      // Check if the webinar is in the future
      if (webinarDate.isAfter(now)) {
        return true;
      }

      // Check if it's today but hasn't started yet
      if (webinarDate.year == now.year &&
          webinarDate.month == now.month &&
          webinarDate.day == now.day) {
        final startTimeParts = startTime.split(':');
        if (startTimeParts.length >= 2) {
          final startHour = int.parse(startTimeParts[0]);
          final startMinute = int.parse(startTimeParts[1]);
          final startDateTime =
              DateTime(now.year, now.month, now.day, startHour, startMinute);

          return now.isBefore(startDateTime);
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Get formatted time string
  String get formattedTime {
    return '$startTime - $endTime';
  }

  // Get formatted date
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}

class Topic {
  final int id;
  final String title;
  final String description;
  final String image;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
    };
  }
}
