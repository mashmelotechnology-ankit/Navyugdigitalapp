import 'package:flutter/material.dart';
import '../models/live_m_class_model.dart';
import '../constants.dart';
import '../screens/live_class_detail_screen.dart';

class LiveClassesHorizontalList extends StatelessWidget {
  final List<LiveMClassModel> liveClasses;
  final Function(LiveMClassModel)? onLiveClassTap;

  const LiveClassesHorizontalList({
    Key? key,
    required this.liveClasses,
    this.onLiveClassTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (liveClasses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Classes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kTextColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to all live classes page if needed
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: kSignUpTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 220,
          margin: const EdgeInsets.only(bottom: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: liveClasses.length,
            itemBuilder: (context, index) {
              final liveClass = liveClasses[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LiveClassDetailScreen(
                          liveClass: liveClass,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    elevation: 3,
                    shadowColor: kBackButtonBorderColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video thumbnail container
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            color: kGreyLightColor.withOpacity(0.2),
                          ),
                          child: Stack(
                            children: [
                              // Video thumbnail image
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: liveClass.thumbnail.isNotEmpty
                                    ? Image.network(
                                        liveClass.thumbnail,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            color: kGreyLightColor
                                                .withOpacity(0.3),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: kDefaultColor,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            color: kGreyLightColor
                                                .withOpacity(0.3),
                                            child: const Icon(
                                              Icons.play_circle_filled,
                                              size: 40,
                                              color: kWhiteColor,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: kGreyLightColor.withOpacity(0.3),
                                        child: const Icon(
                                          Icons.play_circle_filled,
                                          size: 40,
                                          color: kWhiteColor,
                                        ),
                                      ),
                              ),
                              // Live badge
                              if (true)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kRedColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: kWhiteColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              // Upcoming badge
                              if (liveClass.isUpcoming)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kOrangeColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'UPCOMING',
                                      style: TextStyle(
                                        color: kWhiteColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              // Play button overlay
                              const Center(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 50,
                                  color: kWhiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Content section
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title
                                Text(
                                  liveClass.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                // Description
                                Text(
                                  liveClass.description,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: kGreyLightColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                // Date and time
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 10,
                                      color: kGreyLightColor.withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        '${liveClass.formattedDate} | ${liveClass.formattedTime}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color:
                                              kGreyLightColor.withOpacity(0.8),
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
