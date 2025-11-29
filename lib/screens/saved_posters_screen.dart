// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import '../constants.dart';
// import '../providers/saved_posters_provider.dart';
// import '../models/saved_poster_model.dart';

// class SavedPostersScreen extends StatefulWidget {
//   static const routeName = '/saved-posters';
//   const SavedPostersScreen({Key? key}) : super(key: key);

//   @override
//   _SavedPostersScreenState createState() => _SavedPostersScreenState();
// }

// class _SavedPostersScreenState extends State<SavedPostersScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<SavedPostersProvider>(context, listen: false)
//           .loadSavedPosters();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackGroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'My Posters',
//           style: TextStyle(
//             color: kWhiteColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: kDefaultColor,
//         foregroundColor: kWhiteColor,
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           Consumer<SavedPostersProvider>(
//             builder: (context, provider, child) {
//               if (provider.savedPosters.isNotEmpty) {
//                 return PopupMenuButton<String>(
//                   onSelected: (value) {
//                     if (value == 'clear_all') {
//                       _showClearAllDialog();
//                     } else if (value == 'storage_info') {
//                       _showStorageInfo();
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'storage_info',
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline, color: kDefaultColor),
//                           SizedBox(width: 8),
//                           Text('Storage Info'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'clear_all',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete_sweep, color: kRedColor),
//                           SizedBox(width: 8),
//                           Text('Clear All'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//         ],
//       ),
//       body: Consumer<SavedPostersProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(kDefaultColor),
//               ),
//             );
//           }

//           if (provider.savedPosters.isEmpty) {
//             return _buildEmptyState();
//           }

//           return _buildPosterGrid(provider.savedPosters);
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.photo_library_outlined,
//             size: 80,
//             color: kGreyLightColor.withOpacity(0.5),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No Saved Posters',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: kGreyLightColor,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Create your first poster to see it here',
//             style: TextStyle(
//               fontSize: 16,
//               color: kGreyLightColor.withOpacity(0.7),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.add),
//             label: const Text('Create Poster'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: kDefaultColor,
//               foregroundColor: kWhiteColor,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPosterGrid(List<SavedPoster> posters) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.75,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         itemCount: posters.length,
//         itemBuilder: (context, index) {
//           return _buildPosterCard(posters[index]);
//         },
//       ),
//     );
//   }

//   Widget _buildPosterCard(SavedPoster poster) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(12)),
//               child: GestureDetector(
//                 onTap: () => _showPosterPreview(poster),
//                 child: Image.memory(
//                   poster.imageData,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   poster.name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: kTextColor,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   _formatDate(poster.createdAt),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: kGreyLightColor,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildActionButton(
//                       icon: Icons.share,
//                       onTap: () => _sharePoster(poster),
//                       color: kBlueColor,
//                     ),
//                     _buildActionButton(
//                       icon: Icons.download,
//                       onTap: () => _saveToGallery(poster),
//                       color: kGreenColor,
//                     ),
//                     _buildActionButton(
//                       icon: Icons.edit,
//                       onTap: () => _renamePoster(poster),
//                       color: kOrangeColor,
//                     ),
//                     _buildActionButton(
//                       icon: Icons.delete,
//                       onTap: () => _deletePoster(poster),
//                       color: kRedColor,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     required Color color,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(
//           icon,
//           size: 16,
//           color: color,
//         ),
//       ),
//     );
//   }

//   void _showPosterPreview(SavedPoster poster) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: Stack(
//           children: [
//             Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.memory(
//                   poster.imageData,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 40,
//               right: 20,
//               child: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(
//                   Icons.close,
//                   color: kWhiteColor,
//                   size: 30,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _sharePoster(SavedPoster poster) async {
//     try {
//       // Create a temporary file to share
//       await Share.shareXFiles([
//         XFile.fromData(
//           poster.imageData,
//           name: '${poster.name}.png',
//           mimeType: 'image/png',
//         ),
//       ], text: 'Check out my poster: ${poster.name}');
//     } catch (e) {
//       _showErrorSnackBar('Failed to share poster: $e');
//     }
//   }

//   Future<void> _saveToGallery(SavedPoster poster) async {
//     try {
//       final result = await ImageGallerySaver.saveImage(
//         poster.imageData,
//         name: poster.name,
//         quality: 100,
//       );

//       if (result['isSuccess'] == true) {
//         _showSuccessSnackBar('Poster saved to gallery!');
//       } else {
//         _showErrorSnackBar('Failed to save poster to gallery');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to save poster: $e');
//     }
//   }

//   void _renamePoster(SavedPoster poster) {
//     final controller = TextEditingController(text: poster.name);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Rename Poster'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: 'Poster Name',
//             border: OutlineInputBorder(),
//           ),
//           maxLength: 50,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final newName = controller.text.trim();
//               if (newName.isNotEmpty && newName != poster.name) {
//                 final success = await Provider.of<SavedPostersProvider>(
//                   context,
//                   listen: false,
//                 ).renamePoster(poster.id, newName);

//                 if (success) {
//                   _showSuccessSnackBar('Poster renamed successfully!');
//                 } else {
//                   _showErrorSnackBar('Failed to rename poster');
//                 }
//               }
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: kDefaultColor,
//               foregroundColor: kWhiteColor,
//             ),
//             child: const Text('Rename'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _deletePoster(SavedPoster poster) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Poster'),
//         content: Text('Are you sure you want to delete "${poster.name}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final success = await Provider.of<SavedPostersProvider>(
//                 context,
//                 listen: false,
//               ).deletePoster(poster.id);

//               if (success) {
//                 _showSuccessSnackBar('Poster deleted successfully!');
//               } else {
//                 _showErrorSnackBar('Failed to delete poster');
//               }
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: kRedColor,
//               foregroundColor: kWhiteColor,
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showClearAllDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Clear All Posters'),
//         content: const Text(
//             'Are you sure you want to delete all saved posters? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await Provider.of<SavedPostersProvider>(context, listen: false)
//                   .clearAllPosters();
//               _showSuccessSnackBar('All posters cleared successfully!');
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: kRedColor,
//               foregroundColor: kWhiteColor,
//             ),
//             child: const Text('Clear All'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showStorageInfo() {
//     final provider = Provider.of<SavedPostersProvider>(context, listen: false);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Storage Information'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Total Posters: ${provider.savedPosters.length}'),
//             const SizedBox(height: 8),
//             Text('Storage Used: ${provider.getFormattedStorageSize()}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       return 'Today';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: kGreenColor,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: kRedColor,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }
