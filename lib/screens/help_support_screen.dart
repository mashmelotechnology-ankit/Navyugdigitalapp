import 'package:flutter/material.dart';
import 'package:hello_flutter_sdk/hello_flutter_sdk.dart';
import '../constants.dart';
import '../widgets/common_functions.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  static const routeName = '/help-support';

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // Initialize the chat widget height, width and position
  double viewHeight = 80;
  double viewWidth = 80;
  double bottomPosition = 20;
  double rightPosition = 20;
  bool _isChatExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Personal Coach',
          style: TextStyle(
            color: kWhiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: kDefaultColor,
        iconTheme: const IconThemeData(color: kWhiteColor),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kDefaultColor.withOpacity(0.1),
                        kDefaultColor.withOpacity(0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kDefaultColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kDefaultColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.support_agent,
                              color: kDefaultColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How can we help you?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: kTextColor,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Get instant support from our team',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kGreyLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.chat_bubble,
                              title: 'Live Chat',
                              subtitle: 'Chat with support team',
                              onTap: () => _showLiveChatInstructions(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.email,
                              title: 'Email Support',
                              subtitle: 'Send us an email',
                              onTap: () => _showEmailSupport(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // FAQ Section
                _buildFAQSection(),

                const SizedBox(height: 24),

                // Contact Information
                _buildContactInfo(),

                // Add some bottom padding to avoid overlap with chat widget
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Floating Chat Widget
          if (!_isChatExpanded)
            Positioned(
              bottom: bottomPosition,
              right: rightPosition,
              child: SizedBox(
                height: viewHeight,
                width: viewWidth,
                child: ChatWidget(
                  // Custom chat button
                  button: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          kDefaultColor,
                          Color(0xFF1976D2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kDefaultColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Chat",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  uniqueId: "user_unique_id", // Optional: User unique ID
                  widgetToken: "0077a", // Your widget token
                  // uniqueId: "user_unique_id", // Optional: User unique ID
                  // name: "User Name", // Optional: User name
                  widgetColor: kDefaultColor,
                  onLaunchWidget: () {
                    // Expand chat to full screen
                    setState(() {
                      _isChatExpanded = true;
                      viewHeight = MediaQuery.of(context).size.height;
                      viewWidth = MediaQuery.of(context).size.width;
                      bottomPosition = 0;
                      rightPosition = 0;
                    });
                  },
                  onHideWidget: () {
                    // Collapse chat to button
                    setState(() {
                      _isChatExpanded = false;
                      viewHeight = 80;
                      viewWidth = 80;
                      bottomPosition = 20;
                      rightPosition = 20;
                    });
                  },
                ),
              ),
            ),

          // Full screen chat overlay
          if (_isChatExpanded)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: SizedBox(
                  height: viewHeight,
                  width: viewWidth,
                  child: ChatWidget(
                    uniqueId: "user_unique_id", // Optional: User unique ID
                    button: const SizedBox(), // Hidden button when expanded
                    widgetToken: "0077a",
                    widgetColor: kDefaultColor,
                    onLaunchWidget: () {
                      // Already expanded, do nothing
                    },
                    onHideWidget: () {
                      // Collapse chat
                      setState(() {
                        _isChatExpanded = false;
                        viewHeight = 80;
                        viewWidth = 80;
                        bottomPosition = 20;
                        rightPosition = 20;
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kGreyLightColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: kDefaultColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: kGreyLightColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'How do I reset my password?',
        'answer':
            'Go to the login screen and tap "Forgot Password". Enter your email and follow the instructions sent to your email.'
      },
      {
        'question': 'How can I download course materials?',
        'answer':
            'Navigate to your enrolled course, find the lesson with downloadable content, and tap the download icon.'
      },
      {
        'question': 'How do I track my learning progress?',
        'answer':
            'Visit "My Courses" section to view your progress, completed lessons, and certificates earned.'
      },
      {
        'question': 'Can I access courses offline?',
        'answer':
            'Yes, you can download video lessons for offline viewing. Downloaded content is available in the "Downloads" section.'
      },
      {
        'question': 'How do I get a certificate?',
        'answer':
            'Complete all required lessons in a course. Once finished, you can generate and download your certificate from the course completion page.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kTextColor,
          ),
        ),
        const SizedBox(height: 16),
        ...faqs
            .map((faq) => _buildFAQItem(
                  question: faq['question']!,
                  answer: faq['answer']!,
                ))
            .toList(),
      ],
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextColor,
          ),
        ),
        iconColor: kDefaultColor,
        collapsedIconColor: kGreyLightColor,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: kGreyLightColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGreyLightColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'support@academylms.com',
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+1 (555) 123-4567',
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.schedule,
            title: 'Support Hours',
            subtitle: 'Mon-Fri: 9AM-6PM EST',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kDefaultColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kDefaultColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextColor,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: kGreyLightColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLiveChatInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
          'Tap the chat button in the bottom right corner to start a conversation with our support team. We\'re here to help!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showEmailSupport() {
    CommonFunctions.showSuccessToast(
      'Opening email app...\nSend your questions to support@academylms.com',
    );
    // You can implement email launching here using url_launcher
  }
}
