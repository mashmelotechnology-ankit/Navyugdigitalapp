import 'dart:async';
import 'package:flutter/material.dart';
import '../models/topic_live_class_model.dart';
import '../constants.dart';
import '../screens/live_class_detail_screen.dart';
import '../models/live_m_class_model.dart';

class LiveClassesVerticalList extends StatefulWidget {
  final List<TopicLiveClass> liveClasses;

  const LiveClassesVerticalList({
    Key? key,
    required this.liveClasses,
  }) : super(key: key);

  @override
  State<LiveClassesVerticalList> createState() =>
      _LiveClassesVerticalListState();
}

class _LiveClassesVerticalListState extends State<LiveClassesVerticalList> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update countdown every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.liveClasses.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.liveClasses.length,
      itemBuilder: (context, index) {
        final liveClass = widget.liveClasses[index];
        return _buildLiveClassCard(liveClass);
      },
    );
  }

  Widget _buildLiveClassCard(TopicLiveClass liveClass) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kBackButtonBorderColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Convert TopicLiveClass to LiveMClassModel for navigation
          final liveMClassModel = LiveMClassModel(
            id: liveClass.id,
            title: liveClass.title,
            description: liveClass.description,
            videoFile: liveClass.videoFile,
            thumbnail: liveClass.thumbnail,
            isEnroll: liveClass.isEnroll,
            startTime: liveClass.startTime,
            endTime: liveClass.endTime,
            date: liveClass.date,
            status: liveClass.status,
            createdAt: liveClass.createdAt,
            updatedAt: liveClass.updatedAt,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LiveClassDetailScreen(liveClass: liveMClassModel),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kBackButtonBorderColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        liveClass.thumbnail,
                        width: 120,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 80,
                            color: kGreyLightColor.withOpacity(0.2),
                            child: const Icon(
                              Icons.play_circle_outline,
                              size: 30,
                              color: kGreyLightColor,
                            ),
                          );
                        },
                      ),
                      // Play button overlay
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      // Live badge if applicable
                      if (liveClass.timeUntilStart.isNegative)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveClass.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      liveClass.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: kTextColor.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      liveClass.formattedDateTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kDefaultColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Countdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: liveClass.timeUntilStart.isNegative
                            ? Colors.red.withOpacity(0.1)
                            : kDefaultColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: liveClass.timeUntilStart.isNegative
                              ? Colors.red.withOpacity(0.3)
                              : kDefaultColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            liveClass.timeUntilStart.isNegative
                                ? Icons.radio_button_checked
                                : Icons.schedule,
                            size: 14,
                            color: liveClass.timeUntilStart.isNegative
                                ? Colors.red
                                : kDefaultColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            liveClass.countdownString,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: liveClass.timeUntilStart.isNegative
                                  ? Colors.red
                                  : kDefaultColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
