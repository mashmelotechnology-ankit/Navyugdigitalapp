import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/template_model.dart';
import '../providers/template_editor_provider.dart';
import '../widgets/template_editor_widget.dart';

class TemplateEditorScreen extends StatefulWidget {
  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TemplateEditorProvider>().loadTemplates();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.pop(context),
          tooltip: '', // Disable tooltip to prevent ticker conflicts
        ),
        title: Text(
          'Template Editor',
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kDefaultColor,
          unselectedLabelColor: kDarkGreyColor,
          indicatorColor: kDefaultColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Templates'),
            Tab(text: 'Editor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe to prevent conflicts
        children: [
          _buildTemplateSelection(),
          _buildEditor(),
        ],
      ),
    );
  }

  Widget _buildTemplateSelection() {
    return Consumer<TemplateEditorProvider>(
      key: const ValueKey('template_selection_consumer'),
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        if (provider.error != null) {
          return Container(
              color: kBackGroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: kDarkGreyColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: TextStyle(
                        color: kTextColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadTemplates(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDefaultColor,
                        foregroundColor: kWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        }

        return Column(
          children: [
            // Category Filter
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: kWhiteColor,
                border: Border(
                  bottom: BorderSide(
                      color: kDefaultColor.withOpacity(0.1), width: 1),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  final isSelected = category == provider.selectedCategory;

                  return Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          provider.setSelectedCategory(category);
                        }
                      },
                      selectedColor: kDefaultColor.withOpacity(0.15),
                      backgroundColor: kInputBoxBackGroundColor,
                      checkmarkColor: kDefaultColor,
                      side: BorderSide(
                        color: isSelected
                            ? kDefaultColor
                            : kDarkGreyColor.withOpacity(0.3),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? kDefaultColor : kTextColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Templates Grid
            Expanded(
              child: Container(
                color: kBackGroundColor,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.77,
                  ),
                  itemCount: provider.filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = provider.filteredTemplates[index];
                    return _buildTemplateCard(template, provider);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTemplateCard(
      TemplateModel template, TemplateEditorProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.startEditing(template);
        _tabController.animateTo(1); // Switch to editor tab
      },
      child: Container(
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Template Preview
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kInputBoxBackGroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: kDefaultColor.withOpacity(0.1), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildTemplatePreview(template),
                ),
              ),
            ),

            // Template Info
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: kTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.category,
                      style: TextStyle(
                        color: kDarkGreyColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatePreview(TemplateModel template) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: template.size.width,
          height: template.size.height,
          decoration: BoxDecoration(
            color: kWhiteColor,
            border: Border.all(color: kDefaultColor.withOpacity(0.15)),
          ),
          child: Stack(
            children: [
              // Background
              if (template.backgroundImage.isNotEmpty)
                Positioned.fill(
                  child: Image.asset(
                    template.backgroundImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: kInputBoxBackGroundColor,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 24,
                          color: kDarkGreyColor,
                        ),
                      );
                    },
                  ),
                ),

              // Elements (simplified preview)
              ...template.elements.map((element) {
                return Positioned(
                  left: element.position.x,
                  top: element.position.y,
                  child: Container(
                    width: element.size.width,
                    height: element.size.height,
                    child: _buildElementPreview(element),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElementPreview(TemplateElementModel element) {
    switch (element.type) {
      case ElementType.text:
        return Text(
          element.content,
          style: TextStyle(
            fontSize: (element.style.fontSize * 0.6), // Scale down for preview
            fontWeight:
                element.style.isBold ? FontWeight.bold : FontWeight.normal,
            color: _parseColor(element.style.color),
            fontFamily: element.style.fontFamily,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        );
      case ElementType.image:
        return Container(
          decoration: BoxDecoration(
            color: kInputBoxBackGroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.image,
            size: 16,
            color: kDarkGreyColor,
          ),
        );
      case ElementType.shape:
        return Container(
          decoration: BoxDecoration(
            color: _parseColor(element.style.color),
            borderRadius:
                BorderRadius.circular(element.style.borderRadius * 0.6),
          ),
        );
    }
  }

  Widget _buildEditor() {
    return Consumer<TemplateEditorProvider>(
      key: const ValueKey('template_editor_consumer'),
      builder: (context, provider, child) {
        if (!provider.isEditing || provider.currentTemplate == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.design_services,
                  size: 64,
                  color: kDarkGreyColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a template to start editing',
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDefaultColor,
                  ),
                  child: const Text(
                    'Choose Template',
                    style: TextStyle(color: kWhiteColor),
                  ),
                ),
              ],
            ),
          );
        }

        return TemplateEditorWidget(
          initialTemplate: provider.currentTemplate!,
        );
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(
          int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.black;
    }
  }
}
