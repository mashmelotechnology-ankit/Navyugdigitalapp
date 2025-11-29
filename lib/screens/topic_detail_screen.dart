import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/topic_live_class_model.dart';
import '../models/topic_model.dart';
import '../widgets/appbar_one.dart';
import '../widgets/live_classes_vertical_list.dart';

class TopicDetailScreen extends StatefulWidget {
  final TopicModel topic;

  const TopicDetailScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  bool _isLoading = true;
  TopicLiveClassResponse? _response;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTopicLiveClasses();
  }

  Future<void> _fetchTopicLiveClasses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString("access_token");
      final url = '$baseUrl/api/topic-live-class?topic_id=${widget.topic.id}';
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _response = TopicLiveClassResponse.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load live classes';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBarOne(
        title: widget.topic.title,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kDefaultColor),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: kTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchTopicLiveClasses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDefaultColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_response == null || _response!.liveMClass.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: kGreyLightColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No live classes available for this topic',
              style: TextStyle(
                fontSize: 16,
                color: kTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic Banner
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kBackButtonBorderColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                _response!.topic.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: kGreyLightColor.withOpacity(0.2),
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: kGreyLightColor,
                    ),
                  );
                },
              ),
            ),
          ),

          // Topic Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _response!.topic.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _response!.topic.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: kTextColor.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Live Classes (${_response!.liveMClass.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: kTextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Live Classes List
          LiveClassesVerticalList(liveClasses: _response!.liveMClass),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
