import 'package:flutter/material.dart';
import '../models/webinar_model.dart';
import '../constants.dart';
import '../screens/webinar_detail_screen.dart';

class WebinarsHorizontalList extends StatelessWidget {
  final List<WebinarModel> webinars;
  final Function(WebinarModel)? onWebinarTap;

  const WebinarsHorizontalList({
    Key? key,
    required this.webinars,
    this.onWebinarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (webinars.isEmpty) {
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
                'Live Webinars',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kTextColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to all webinars page if needed
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
          height: 240,
          margin: const EdgeInsets.only(bottom: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: webinars.length,
            itemBuilder: (context, index) {
              final webinar = webinars[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebinarDetailScreen(
                          webinar: webinar,
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
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Stack(
                                children: [
                                  // Video thumbnail image
                                  webinar.thumbnail.isNotEmpty
                                      ? Image.network(
                                          webinar.thumbnail,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: kGreyLightColor
                                                  .withOpacity(0.3),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
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
                                          color:
                                              kGreyLightColor.withOpacity(0.3),
                                          child: const Icon(
                                            Icons.play_circle_filled,
                                            size: 40,
                                            color: kWhiteColor,
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
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                  if (webinar.isUpcoming)
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
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                  webinar.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                // Topic
                                Text(
                                  webinar.topic.title,
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
                                        '${webinar.formattedDate} | ${webinar.formattedTime}',
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
