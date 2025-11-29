import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/live_m_class_model.dart';
import '../widgets/appbar_one.dart';
import '../widgets/common_functions.dart';
import '../widgets/from_network.dart';
import 'tab_screen.dart';

class LiveClassDetailScreen extends StatefulWidget {
  static const routeName = '/live-class-details';
  final LiveMClassModel liveClass;

  const LiveClassDetailScreen({
    Key? key,
    required this.liveClass,
  }) : super(key: key);

  @override
  State<LiveClassDetailScreen> createState() => _LiveClassDetailScreenState();
}

class _LiveClassDetailScreenState extends State<LiveClassDetailScreen> {
  bool _isLoading = false;
  bool _isEnrolling = false;
  String? token;

  @override
  void initState() {
    super.initState();
    _initializeToken();
  }

  void _initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('access_token');
    });
  }

  Future<void> _enrollInLiveClass() async {
    if (token == null || token!.isEmpty) {
      CommonFunctions.showWarningToast('Please login first');
      return;
    }

    setState(() {
      _isEnrolling = true;
    });

    try {
      final url = '$baseUrl/api/live_m_class_enroll/${widget.liveClass.id}';
      print('Enrolling in live class: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          CommonFunctions.showSuccessToast(
              data['message'] ?? 'Successfully enrolled in live class!');

          // Navigate to My Courses screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const TabsScreen(pageIndex: 1),
            ),
          );
        } else {
          CommonFunctions.showWarningToast(
              data['message'] ?? 'Failed to enroll in live class');
        }
      } else if (response.statusCode == 401) {
        CommonFunctions.showWarningToast('Session expired. Please login again');
      } else {
        CommonFunctions.showWarningToast(
            data['message'] ?? 'Failed to enroll in live class');
      }
    } catch (error) {
      print('Error enrolling in live class: $error');
      CommonFunctions.showWarningToast('Network error. Please try again');
    } finally {
      setState(() {
        _isEnrolling = false;
      });
    }
  }

  String _formatDateTime(String date, String time) {
    try {
      final dateTime = DateTime.parse('$date $time');
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(time)}';
    } catch (e) {
      return '$date at $time';
    }
  }

  String _formatTime(String time) {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  bool _isWithinTimeWindow() {
    try {
      final now = DateTime.now();

      // Parse start and end times
      final startDateTime = DateTime.parse(
          '${widget.liveClass.date} ${widget.liveClass.startTime}');
      final endDateTime = DateTime.parse(
          '${widget.liveClass.date} ${widget.liveClass.endTime}');

      return now.isAfter(startDateTime) && now.isBefore(endDateTime);
    } catch (e) {
      print('Error parsing date/time: $e');
      return false;
    }
  }

  void _handleVideoPlayback() {
    // Check if user is enrolled
    if (widget.liveClass.isEnroll != 1) {
      CommonFunctions.showWarningToast(
          'You must be enrolled to access this content.');
      return;
    }

    // Check if current time is within the allowed window
    if (!_isWithinTimeWindow()) {
      CommonFunctions.showWarningToast(
          'You are not allowed to access this content at this time.');
      return;
    }

    // Check if video is available
    if (widget.liveClass.videoFile.isEmpty) {
      CommonFunctions.showWarningToast('Video not available yet');
      return;
    }

    // All checks passed, navigate to video player
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayVideoFromNetwork(
          courseId: widget.liveClass.id,
          videoUrl: widget.liveClass.videoFile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarOne(logo: 'logo.png'),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: kBackGroundColor,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kDefaultColor),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Video/Thumbnail section
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.grey[200],
                                child: Image.network(
                                  widget.liveClass.thumbnail,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                  colorBlendMode: BlendMode.dstATop,
                                  color: Colors.black.withOpacity(0.6),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: kDefaultColor,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: kGreyLightColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Play button
                            Positioned.fill(
                              child: Center(
                                child: ClipOval(
                                  child: InkWell(
                                    onTap: _handleVideoPlayback,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.95),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          'assets/images/play.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Live/Upcoming badge
                            if (widget.liveClass.isLive ||
                                widget.liveClass.isUpcoming)
                              Positioned(
                                top: 15,
                                left: 15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.liveClass.isLive
                                        ? kRedColor
                                        : kOrangeColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.liveClass.isLive
                                        ? 'LIVE'
                                        : 'UPCOMING',
                                    style: const TextStyle(
                                      color: kWhiteColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Title section
                      Text(
                        widget.liveClass.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: kTextColor,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.liveClass.status
                              ? kGreenPurchaseColor.withOpacity(0.1)
                              : kOrangeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.liveClass.status ? 'Active' : 'Scheduled',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: widget.liveClass.status
                                ? kGreenPurchaseColor
                                : kOrangeColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Date and time info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kBackButtonBorderColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: kDefaultColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Schedule',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: kTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDateTime(widget.liveClass.date,
                                  widget.liveClass.startTime),
                              style: const TextStyle(
                                fontSize: 14,
                                color: kGreyLightColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duration: ${widget.liveClass.startTime} - ${widget.liveClass.endTime}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: kGreyLightColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description section
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kBackButtonBorderColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.liveClass.description.isNotEmpty
                              ? widget.liveClass.description
                              : 'Join this interactive live class to enhance your learning experience. Our expert instructors will provide real-time guidance and answer your questions during the session.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: kGreyLightColor,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Conditional Enrollment/Enrolled status
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: widget.liveClass.isEnroll == 1
                            ? Container(
                                decoration: BoxDecoration(
                                  color: kGreenColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: kGreenColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: kGreenColor,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Already Joined',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: kGreenColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                onPressed:
                                    _isEnrolling ? null : _enrollInLiveClass,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kDefaultColor,
                                  foregroundColor: kWhiteColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isEnrolling
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CupertinoActivityIndicator(
                                            color: kWhiteColor,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Enrolling...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.school),
                                          SizedBox(width: 12),
                                          Text(
                                            'Join',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
