import 'dart:async';
import 'package:flutter/material.dart';
import '../models/slider_model.dart';
import '../constants.dart';

class SliderCarousel extends StatefulWidget {
  final List<SliderModel> sliders;

  const SliderCarousel({
    Key? key,
    required this.sliders,
  }) : super(key: key);

  @override
  State<SliderCarousel> createState() => _SliderCarouselState();
}

class _SliderCarouselState extends State<SliderCarousel> {
  int _currentIndex = 0;
  PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.sliders.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_currentIndex < widget.sliders.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sliders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.sliders.length,
              itemBuilder: (context, index) {
                final slider = widget.sliders[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: kBackButtonBorderColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Stack(
                      children: [
                        // Image
                        Container(
                          color: Colors.grey[200],
                          child: Image.network(
                            slider.image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: kGreyLightColor.withOpacity(0.1),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: kDefaultColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: kGreyLightColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: kGreyLightColor,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(
                                        color: kGreyLightColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Dots indicator
        if (widget.sliders.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.sliders.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    entry.key,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? kDefaultColor
                        : kGreyLightColor.withOpacity(0.4),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
