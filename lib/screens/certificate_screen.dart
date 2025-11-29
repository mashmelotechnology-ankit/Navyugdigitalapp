import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/certificate_provider.dart';
import '../widgets/common_functions.dart';
import 'certificate_form_screen.dart';

class CertificateScreen extends StatefulWidget {
  static const routeName = '/certificate';

  const CertificateScreen({Key? key}) : super(key: key);

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch certificate data when screen loads
    Future.microtask(() {
      if (mounted) {
        Provider.of<CertificateProvider>(context, listen: false)
            .fetchCertificateData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diploma Certificates',
          style: TextStyle(
            color: kWhiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: kDefaultColor,
        iconTheme: const IconThemeData(color: kWhiteColor),
        elevation: 0,
      ),
      body: Consumer<CertificateProvider>(
        builder: (context, certificateProvider, child) {
          if (certificateProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(
                    color: kDefaultColor,
                    radius: 15,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading certificate data...',
                    style: TextStyle(
                      color: kGreyLightColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (certificateProvider.error.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: kRedColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Certificates',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      certificateProvider.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kGreyLightColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        certificateProvider.clearError();
                        certificateProvider.fetchCertificateData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDefaultColor,
                        foregroundColor: kWhiteColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final syllabus = certificateProvider.certificateData?.syllabus ?? [];

          if (syllabus.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: kGreyLightColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Sylabus Available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete some syllabus to generate certificates',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: kGreyLightColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kDefaultColor.withOpacity(0.1),
                        kDefaultColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kDefaultColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kDefaultColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              color: kWhiteColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Generate Certificates',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: kTextColor,
                                  ),
                                ),
                                Text(
                                  'Create professional certificates for your completed syllabus',
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
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Completed courses section
                const Text(
                  'All Syllabus Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${syllabus.length} syllabus${syllabus.length != 1 ? 's' : ''} available',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kGreyLightColor,
                  ),
                ),

                const SizedBox(height: 16),

                // Course list
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: syllabus.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final syllabusItem = syllabus[index];
                    return Card(
                      elevation: 2,
                      shadowColor: kBackButtonBorderColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CertificateFormScreen(
                                syllabusModel: syllabusItem,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Course thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  syllabusItem.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: kGreyLightColor.withOpacity(0.3),
                                      child: const Icon(
                                        Icons.school,
                                        color: kGreyLightColor,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Course details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      syllabusItem.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: kTextColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),

                              // Arrow icon
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: kGreyLightColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
