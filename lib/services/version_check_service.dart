import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckService {
  // ========== CONFIGURATION - UPDATE THESE VALUES WHEN RELEASING NEW VERSION ==========
  
  /// The latest version available on Play Store / App Store
  static const String latestVersion = '1.0.4';
  
  /// Minimum version required to use the app (users below this MUST update)
  static const String minRequiredVersion = '1.0.3';
  
  /// Enable force update (true = users must update, false = optional update)
  static const bool enableForceUpdate = true;
  
  /// Message to show in update dialog
  static const String updateMessage = 
      'A new version of the app is available with exciting new features and bug fixes. Update now to continue using the app!';
  
  /// Play Store URL (Android)
  static const String androidUrl = 
      'https://play.google.com/store/apps/details?id=com.navyugdigital.userapp';
  
  /// App Store URL (iOS)
  static const String iosUrl = 
      'https://apps.apple.com/app/your-app-id';
  
  // ===================================================================================

  static Future<Map<String, dynamic>> checkForUpdate() async {
    try {
      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // Compare versions
      bool needsUpdate = _compareVersions(
        currentVersion,
        latestVersion,
      ) < 0;

      bool forceUpdate = enableForceUpdate && _compareVersions(
        currentVersion,
        minRequiredVersion,
      ) < 0;

      return {
        'needs_update': needsUpdate,
        'force_update': forceUpdate,
        'current_version': currentVersion,
        'latest_version': latestVersion,
        'min_required_version': minRequiredVersion,
        'update_message': updateMessage,
        'update_url': Platform.isAndroid ? androidUrl : iosUrl,
      };
    } catch (e) {
      print('Error checking version: $e');
      return {
        'needs_update': false,
        'force_update': false,
        'error': e.toString(),
      };
    }
  }

  /// Compare version strings (e.g., "1.2.3" vs "1.3.0")
  /// Returns: -1 if v1 < v2, 0 if equal, 1 if v1 > v2
  static int _compareVersions(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Ensure both have 3 parts
    while (v1Parts.length < 3) v1Parts.add(0);
    while (v2Parts.length < 3) v2Parts.add(0);

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }

    return 0; // Equal
  }
}
