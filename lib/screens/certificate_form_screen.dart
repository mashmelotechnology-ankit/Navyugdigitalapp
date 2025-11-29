import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../models/certificate_model.dart';
import '../providers/certificate_provider.dart';
import '../widgets/common_functions.dart';

class CertificateFormScreen extends StatefulWidget {
  final SyllabusModel syllabusModel;

  const CertificateFormScreen({
    Key? key,
    required this.syllabusModel,
  }) : super(key: key);

  @override
  State<CertificateFormScreen> createState() => _CertificateFormScreenState();
}

class _CertificateFormScreenState extends State<CertificateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _courseDurationController = TextEditingController();
  final _courseTitleController = TextEditingController();
  final _courseCompletionDateController = TextEditingController();
  final _certificateDownloadDateController = TextEditingController();

  // New variables for dropdowns and photo
  String _selectedDurationUnit = 'Days';
  String _selectedCourseLevel = 'Beginner';
  File? _studentPhoto;
  final ImagePicker _picker = ImagePicker();

  // Duration unit options
  final List<String> _durationUnits = ['Days', 'Weeks', 'Months', 'Years'];

  // Course level options
  final List<String> _courseLevels = ['Beginner', 'Intermediate', 'Expert'];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    // Pre-fill form with course data
    _courseTitleController.text = widget.syllabusModel.title;

    // Set current date as default download date
    final now = DateTime.now();
    _certificateDownloadDateController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Set completion date as current date by default
    _courseCompletionDateController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _fatherNameController.dispose();
    _courseDurationController.dispose();
    _mobileController.dispose();
    _courseTitleController.dispose();
    _courseCompletionDateController.dispose();
    _certificateDownloadDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kDefaultColor,
              onPrimary: kWhiteColor,
              surface: kWhiteColor,
              onSurface: kTextColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  // Student photo picker methods
  Future<void> _pickStudentPhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _studentPhoto = File(pickedFile.path);
        });
      }
    } catch (e) {
      CommonFunctions.showWarningToast('Error selecting image: $e');
    }
  }

  Future<void> _takeStudentPhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _studentPhoto = File(pickedFile.path);
        });
      }
    } catch (e) {
      CommonFunctions.showWarningToast('Error taking photo: $e');
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickStudentPhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _takeStudentPhoto();
                },
              ),
              if (_studentPhoto != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _studentPhoto = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _generateCertificate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final certificateProvider =
        Provider.of<CertificateProvider>(context, listen: false);

    if (certificateProvider.selectedTemplateUrl.isEmpty) {
      CommonFunctions.showWarningToast('Please select a certificate template');
      return;
    }

    final request = CertificateGenerateRequestModel(
      syllabusId: widget.syllabusModel.id,
      templateId: certificateProvider.selectedTemplateId,
      syllabusTitle: widget.syllabusModel.title,
      courseDuration:
          '${_courseDurationController.text.trim()} ${_selectedDurationUnit.toLowerCase()}',
      studentName: _studentNameController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      courseCompletionDate: _courseCompletionDateController.text.trim(),
      certificateDownloadDate: _certificateDownloadDateController.text.trim(),
      courseLevel: _selectedCourseLevel,
      studentPhoto: _studentPhoto,
    );

    final success = await certificateProvider.generateCertificate(request);

    if (success) {
      CommonFunctions.showSuccessToast(
          'Certificate generated and downloaded successfully!');
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      CommonFunctions.showWarningToast(
          certificateProvider.generationError.isNotEmpty
              ? certificateProvider.generationError
              : 'Failed to generate certificate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate Certificate',
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course info card
                  Card(
                    elevation: 2,
                    shadowColor: kBackButtonBorderColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.syllabusModel.image,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.syllabusModel.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: kTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Template selection section
                  const Text(
                    'Select Certificate Template',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (certificateProvider.allTemplates.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: certificateProvider.allTemplates.length,
                        itemBuilder: (context, index) {
                          final templateUrl =
                              certificateProvider.allTemplates[index];
                          final isSelected =
                              certificateProvider.selectedTemplateIndex ==
                                  index;

                          return GestureDetector(
                            onTap: () {
                              certificateProvider.selectTemplate(index);
                            },
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? kDefaultColor
                                      : kGreyLightColor.withOpacity(0.3),
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      templateUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color:
                                              kGreyLightColor.withOpacity(0.3),
                                          child: const Icon(
                                            Icons.image,
                                            color: kGreyLightColor,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: kDefaultColor.withOpacity(0.2),
                                        child: const Center(
                                          child: Icon(
                                            Icons.check_circle,
                                            color: kDefaultColor,
                                            size: 32,
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

                  const SizedBox(height: 32),

                  // Form fields section
                  const Text(
                    'Certificate Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Student Name field
                  TextFormField(
                    controller: _studentNameController,
                    decoration: InputDecoration(
                      labelText: 'Student Name *',
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, color: kTextColor),
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kDefaultColor),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Student name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Father Name field
                  TextFormField(
                    controller: _fatherNameController,
                    decoration: InputDecoration(
                      labelText: 'Father Name *',
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, color: kTextColor),
                      hintText: 'Enter father\'s full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kDefaultColor),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Father name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  //  Mobile field
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile *',
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, color: kTextColor),
                      hintText: 'Enter mobile number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kDefaultColor),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mobile number is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Student Photo Picker
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: kGreyLightColor.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Student Photo',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: kTextColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _showPhotoOptions,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: kDefaultColor.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(8),
                                    color: kInputBoxBackGroundColor,
                                  ),
                                  child: _studentPhoto != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            _studentPhoto!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.camera_alt,
                                                color: kGreyLightColor),
                                            SizedBox(height: 4),
                                            Text(
                                              'Add',
                                              style: TextStyle(
                                                color: kGreyLightColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _studentPhoto != null
                                          ? 'Photo selected'
                                          : 'No photo selected',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: kTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: _showPhotoOptions,
                                      child: Text(
                                        _studentPhoto != null
                                            ? 'Change photo'
                                            : 'Tap to add photo',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: kDefaultColor,
                                          decoration: TextDecoration.underline,
                                        ),
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
                  ),

                  const SizedBox(height: 16),

                  // Course Duration field with dropdown
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _courseDurationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Duration *',
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, color: kTextColor),
                            hintText: 'Enter number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: kDefaultColor),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Duration is required';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedDurationUnit,
                          decoration: InputDecoration(
                            labelText: 'Unit *',
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, color: kTextColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: kDefaultColor),
                            ),
                          ),
                          items: _durationUnits.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedDurationUnit = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Row with Course Title and Instructor
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _courseTitleController,
                          decoration: InputDecoration(
                            labelText: 'Syllabus Title *',
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, color: kTextColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: kDefaultColor),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Syllabus title is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCourseLevel,
                          decoration: InputDecoration(
                            labelText: 'Course Level *',
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, color: kTextColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: kDefaultColor),
                            ),
                          ),
                          items: _courseLevels.map((String level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCourseLevel = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date fields
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _courseCompletionDateController,
                          readOnly: true,
                          onTap: () =>
                              _selectDate(_courseCompletionDateController),
                          decoration: InputDecoration(
                            labelText: 'Course Completion Date *',
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, color: kTextColor),
                            suffixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: kDefaultColor),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Completion date is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _certificateDownloadDateController,
                          readOnly: true,
                          onTap: () =>
                              _selectDate(_certificateDownloadDateController),
                          decoration: InputDecoration(
                            labelText: 'Certificate Date *',
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, color: kTextColor),
                            suffixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: kDefaultColor),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Certificate date is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: certificateProvider.isGenerating ||
                              certificateProvider.isDownloading
                          ? null
                          : _generateCertificate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDefaultColor,
                        foregroundColor: kWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: certificateProvider.isGenerating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoActivityIndicator(
                                  color: kWhiteColor,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Generating Certificate...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : certificateProvider.isDownloading
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: kWhiteColor,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Downloading... ${(certificateProvider.downloadProgress * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: certificateProvider
                                            .downloadProgress,
                                        backgroundColor:
                                            kWhiteColor.withOpacity(0.3),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                kWhiteColor),
                                        minHeight: 2,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.download),
                                    SizedBox(width: 8),
                                    Text(
                                      'Generate & Download',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Error message
                  if (certificateProvider.generationError.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kRedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: kRedColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: kRedColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              certificateProvider.generationError,
                              style: const TextStyle(
                                color: kRedColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              certificateProvider.clearGenerationError();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: kRedColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
