class LiveMClassModel {
  final int id;
  final String title;
  final String description;
  final String videoFile;
  final int isEnroll;
  final String startTime;
  final String endTime;
  final String thumbnail;
  final String date;
  final bool status;
  final String createdAt;
  final String updatedAt;

  LiveMClassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoFile,
    required this.startTime,required this.isEnroll,
    required this.endTime,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveMClassModel.fromJson(Map<String, dynamic> json) {
    return LiveMClassModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoFile: json['video_file'] ?? '',
      isEnroll: json['is_enroll'] ?? 0,
      startTime: json['start_time'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      endTime: json['end_time'] ?? '',
      date: json['date'] ?? '',
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
      'video_file': videoFile,
      'start_time': startTime,
      'end_time': endTime,
      'date': date,
      'thumbnail': thumbnail,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method to check if live class is currently live
  bool get isLive {
    try {
      final now = DateTime.now();
      final classDate = DateTime.parse(date);

      // Check if the live class is today
      if (classDate.year == now.year &&
          classDate.month == now.month &&
          classDate.day == now.day) {
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

  // Helper method to check if live class is upcoming
  bool get isUpcoming {
    try {
      final now = DateTime.now();
      final classDate = DateTime.parse(date);

      // Check if the live class is in the future
      if (classDate.isAfter(now)) {
        return true;
      }

      // Check if it's today but hasn't started yet
      if (classDate.year == now.year &&
          classDate.month == now.month &&
          classDate.day == now.day) {
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
