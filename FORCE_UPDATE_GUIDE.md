# Force Update Implementation Guide (App-Level)

## ✅ What's Implemented

A complete force update system that works entirely within the app - **NO BACKEND REQUIRED!**

### Features:
- ✅ Automatic version checking on app launch
- ✅ Beautiful update dialog with current/latest version display
- ✅ Optional updates (user can dismiss)
- ✅ Force updates (blocks app access until updated)
- ✅ Direct Play Store/App Store navigation
- ✅ Customizable update messages
- ✅ **Works completely offline - no API needed**

## 📁 Files Created

1. **`lib/models/app_version_model.dart`**
   - Model for version data

2. **`lib/services/version_check_service.dart`**
   - ⭐ **MAIN CONFIGURATION FILE** - Update this when releasing new versions
   - Service to check version and compare
   - All settings in one place

3. **`lib/widgets/force_update_dialog.dart`**
   - Beautiful update dialog UI
   - Shows current vs latest version

4. **`lib/screens/splash.dart`** (Modified)
   - Added version check on app start
   - Shows dialog before navigation

## 🚀 How It Works

### Flow:
```
App Launch → Splash Screen → Compare Versions (In-App)
                                    ↓
              Force Update Required? ← Yes → Block App + Show Dialog
                         ↓ No
              Optional Update? → Yes → Show Dismissible Dialog
                         ↓ No
                  Continue to App
```

### Version Comparison:
- **Current Version**: Read from `pubspec.yaml` automatically
- **Latest Version**: Configured in `version_check_service.dart`
- **Min Required**: Configured in `version_check_service.dart`

## ⚙️ How to Release a New Version

### Step 1: Update pubspec.yaml

```yaml
version: 1.0.4+10  # Change this
```

### Step 2: Update Version Check Service

Open `lib/services/version_check_service.dart` and update:

```dart
// ========== UPDATE THESE VALUES ==========

/// Latest version available
static const String latestVersion = '1.0.4';  // ← Change this

/// Minimum required version
static const String minRequiredVersion = '1.0.3';  // ← Change this

/// Enable force update
static const bool enableForceUpdate = true;  // ← true or false

/// Update message
static const String updateMessage = 
    'Your custom message here';  // ← Customize this

/// Play Store URL
static const String androidUrl = 
    'https://play.google.com/store/apps/details?id=com.navyugdigital.userapp';

/// App Store URL
static const String iosUrl = 
    'https://apps.apple.com/app/your-app-id';
```

### Step 3: Build and Release

```bash
# Build release APK/AAB
flutter build appbundle --release

# Upload to Play Store
# Update the version check service with Play Store URL
```

## 📊 Version Scenarios

| Current | Min Required | Latest | Force Update | Result |
|---------|--------------|--------|--------------|--------|
| 1.0.2 | 1.0.3 | 1.0.4 | true | **Force Update** (blocks app) |
| 1.0.3 | 1.0.3 | 1.0.4 | false | Optional Update (can dismiss) |
| 1.0.4 | 1.0.3 | 1.0.4 | - | No update needed |
| 1.0.5 | 1.0.3 | 1.0.4 | - | No update needed |

## 🎯 Common Use Cases

### Scenario 1: Optional Update (Recommended for Minor Updates)
```dart
static const String latestVersion = '1.0.4';
static const String minRequiredVersion = '1.0.3';
static const bool enableForceUpdate = false;  // User can skip
```
**Result**: Users on 1.0.3 see "Update Available" but can dismiss it

### Scenario 2: Force Update (For Critical Fixes)
```dart
static const String latestVersion = '1.0.4';
static const String minRequiredVersion = '1.0.4';  // Same as latest
static const bool enableForceUpdate = true;  // Must update
```
**Result**: Users below 1.0.4 MUST update to continue

### Scenario 3: Gradual Rollout
```dart
static const String latestVersion = '1.0.5';  // New version
static const String minRequiredVersion = '1.0.3';  // Still allow old
static const bool enableForceUpdate = false;
```
**Result**: Users see update available but can continue with 1.0.3+

## 🎨 Customization

### Change Update Message

Edit `version_check_service.dart`:
```dart
static const String updateMessage = 
    'New features:\n' +
    '• Bug fixes\n' +
    '• Performance improvements\n' +
    '• New UI design';
```

### Change Dialog Colors

Edit `lib/widgets/force_update_dialog.dart`:
```dart
gradient: LinearGradient(
  colors: [
    Color(0xFF6C63FF),  // Your color
    Color(0xFF5A52E0),  // Your color
  ],
)
```

### Disable Force Update Completely

```dart
static const bool enableForceUpdate = false;
```

## 📱 Testing Different Scenarios

### Test Optional Update:
1. In `pubspec.yaml`: Set version to `1.0.3+9`
2. In `version_check_service.dart`:
   ```dart
   latestVersion = '1.0.4'
   minRequiredVersion = '1.0.3'
   enableForceUpdate = false
   ```
3. Run app → Should show "Update Available" (can dismiss)

### Test Force Update:
1. In `pubspec.yaml`: Set version to `1.0.2+8`
2. In `version_check_service.dart`:
   ```dart
   latestVersion = '1.0.4'
   minRequiredVersion = '1.0.3'
   enableForceUpdate = true
   ```
3. Run app → Should show "Update Required" (cannot dismiss)

### Test No Update:
1. In `pubspec.yaml`: Set version to `1.0.4+10`
2. In `version_check_service.dart`:
   ```dart
   latestVersion = '1.0.4'
   ```
3. Run app → No dialog, proceeds normally

## 📝 Release Workflow

### For New Release:

1. **Develop & Test** your new features

2. **Update pubspec.yaml**
   ```yaml
   version: 1.0.4+10
   ```

3. **Build Release**
   ```bash
   flutter build appbundle --release
   ```

4. **Upload to Play Store**
   - Wait for approval
   - Get the published URL

5. **Update Old Version's Code**
   - Checkout previous version branch/tag
   - Update `version_check_service.dart` to point to new version
   - Build and release as patch update
   
   OR simply update Play Store listing to force users to download latest

6. **For Next Version**
   - Keep updating `latestVersion` to prompt users

## 🔧 Advanced Configuration

### Phased Rollout

Release to small percentage first:
```dart
// Week 1: Soft launch
latestVersion = '1.0.4'
minRequiredVersion = '1.0.2'  // Allow old versions
enableForceUpdate = false

// Week 2: After testing
latestVersion = '1.0.4'
minRequiredVersion = '1.0.3'  // Raise the bar
enableForceUpdate = false

// Week 3: Force update
latestVersion = '1.0.4'
minRequiredVersion = '1.0.4'  // Everyone must update
enableForceUpdate = true
```

### Emergency Hotfix

Critical bug found in 1.0.3:
```dart
// Release 1.0.4 immediately
latestVersion = '1.0.4'
minRequiredVersion = '1.0.4'  // Block 1.0.3
enableForceUpdate = true
updateMessage = 'Critical security update required!'
```

## ✅ Advantages of App-Level Implementation

- ✅ No backend API needed
- ✅ Works offline
- ✅ Instant updates to version info
- ✅ Simple to configure
- ✅ No server maintenance
- ✅ Free (no hosting costs)

## ⚠️ Important Notes

1. **Update in Stages**: When releasing version 1.0.4:
   - First, publish 1.0.4 to Play Store
   - Then release a patch to 1.0.3 that updates the version check settings
   - This ensures users are directed to available version

2. **Play Store URL**: Update the URL after your app is published:
   ```dart
   static const String androidUrl = 
       'https://play.google.com/store/apps/details?id=com.navyugdigital.userapp';
   ```

3. **Version Format**: Always use semantic versioning (MAJOR.MINOR.PATCH)
   - `1.0.4` → Major: 1, Minor: 0, Patch: 4

4. **Testing**: Always test force update before releasing to ensure it blocks properly

## 🎯 Current Configuration

**App Version**: `1.0.3+9` (from pubspec.yaml)
**Latest Version**: Check `lib/services/version_check_service.dart`
**Package Name**: `com.navyugdigital.userapp`

---

**That's it!** No backend, no API, just update two files and you're done! 🚀

### Features:
- ✅ Automatic version checking on app launch
- ✅ Beautiful update dialog with current/latest version display
- ✅ Optional updates (user can dismiss)
- ✅ Force updates (blocks app access until updated)
- ✅ Direct Play Store/App Store navigation
- ✅ Customizable update messages
- ✅ Graceful error handling

## 📁 Files Created

1. **`lib/models/app_version_model.dart`**
   - Model for version data from API

2. **`lib/services/version_check_service.dart`**
   - Service to check version and compare
   - Makes API call to `/api/app_version`

3. **`lib/widgets/force_update_dialog.dart`**
   - Beautiful update dialog UI
   - Shows current vs latest version
   - Update Now / Maybe Later buttons

4. **`lib/screens/splash.dart`** (Modified)
   - Added version check on app start
   - Shows dialog before navigation

5. **`FORCE_UPDATE_API.md`**
   - Complete API documentation
   - Laravel implementation example

## 🚀 How It Works

### Flow:
```
App Launch → Splash Screen → Version Check API → Compare Versions
                                                        ↓
                          Force Update Required? ← Yes → Block App + Show Dialog
                                   ↓ No
                          Optional Update? → Yes → Show Dismissible Dialog
                                   ↓ No
                            Continue to App
```

### Version Comparison Logic:
- **Current Version**: `1.0.3` (from pubspec.yaml)
- **Latest Version**: `1.0.4` (from API)
- **Min Required**: `1.0.3` (from API)

**Scenarios:**

| Current | Min Required | Latest | Result |
|---------|--------------|--------|--------|
| 1.0.2 | 1.0.3 | 1.0.4 | **Force Update** (blocks app) |
| 1.0.3 | 1.0.3 | 1.0.4 | Optional Update (can dismiss) |
| 1.0.4 | 1.0.3 | 1.0.4 | No update needed |
| 1.0.5 | 1.0.3 | 1.0.4 | No update needed |

## ⚙️ Backend Setup Required

### 1. Create API Endpoint

Add to your Laravel backend: `/api/app_version`

**Response Format:**
```json
{
  "success": true,
  "data": {
    "latest_version": "1.0.4",
    "min_required_version": "1.0.3",
    "force_update": true,
    "update_message": "New features and bug fixes available. Update now!",
    "android_url": "https://play.google.com/store/apps/details?id=com.navyugdigital.userapp",
    "ios_url": "https://apps.apple.com/app/your-app-id"
  }
}
```

### 2. Laravel Controller Example

```php
// app/Http/Controllers/Api/AppVersionController.php
public function getAppVersion()
{
    return response()->json([
        'success' => true,
        'data' => [
            'latest_version' => '1.0.4',
            'min_required_version' => '1.0.3',
            'force_update' => true,
            'update_message' => 'New features and bug fixes available. Update now!',
            'android_url' => 'https://play.google.com/store/apps/details?id=com.navyugdigital.userapp',
            'ios_url' => 'https://apps.apple.com/app/your-app-id'
        ]
    ]);
}
```

### 3. Add Route

```php
// routes/api.php
Route::get('/app_version', [AppVersionController::class, 'getAppVersion']);
```

## 🎨 Customization

### Change Dialog Colors

Edit `lib/widgets/force_update_dialog.dart`:

```dart
// Change gradient colors
gradient: LinearGradient(
  colors: [
    Color(0xFF6C63FF),  // Change this
    Color(0xFF5A52E0),  // Change this
  ],
)
```

### Change Update Message

Update via API response or modify the fallback in `splash.dart`:

```dart
message: updateInfo['update_message'] ??
    'Your custom message here',
```

### Disable Force Update

On backend, set:
```json
{
  "force_update": false
}
```

## 📱 Testing

### Test Optional Update:
1. Set current version in `pubspec.yaml`: `1.0.3+9`
2. Set API response:
   ```json
   {
     "latest_version": "1.0.4",
     "min_required_version": "1.0.3",
     "force_update": false
   }
   ```
3. Launch app → Should show "Update Available" (dismissible)

### Test Force Update:
1. Set current version in `pubspec.yaml`: `1.0.2+8`
2. Set API response:
   ```json
   {
     "latest_version": "1.0.4",
     "min_required_version": "1.0.3",
     "force_update": true
   }
   ```
3. Launch app → Should show "Update Required" (cannot dismiss)

### Test No Update:
1. Set current version in `pubspec.yaml`: `1.0.4+10`
2. Set API response:
   ```json
   {
     "latest_version": "1.0.4",
     "min_required_version": "1.0.3"
   }
   ```
3. Launch app → No dialog, proceeds normally

## 📝 Update Checklist

When releasing a new version:

- [ ] Update version in `pubspec.yaml`
  ```yaml
  version: 1.0.4+10
  ```

- [ ] Build and upload to Play Store

- [ ] Get Play Store URL (after publishing)

- [ ] Update backend API with new version:
  ```json
  {
    "latest_version": "1.0.4",
    "android_url": "https://play.google.com/store/apps/details?id=com.navyugdigital.userapp"
  }
  ```

- [ ] Decide if force update is needed:
  - **Minor bug fixes**: `force_update: false`
  - **Critical fixes/security**: `force_update: true`
  - **Breaking changes**: `force_update: true` with higher `min_required_version`

## 🔧 Troubleshooting

**Dialog not showing?**
- Check API is returning 200 status
- Verify API response format matches model
- Check console for errors: "Version check error: ..."

**Wrong version displayed?**
- Check `pubspec.yaml` version number
- Rebuild app after changing version
- Clear app data and reinstall

**Play Store link not working?**
- Verify package name: `com.navyugdigital.userapp`
- Ensure app is published (not draft)
- Use full URL format

**Force update not blocking?**
- Verify `force_update: true` in API
- Check `min_required_version` is higher than current
- Ensure dialog has `barrierDismissible: false`

## 📊 Current Configuration

**App Version**: `1.0.3+9` (from pubspec.yaml)
**Package Name**: `com.navyugdigital.userapp`
**API Endpoint**: `https://navyugdigital.in/api/app_version`

## 🎯 Next Steps

1. Implement the backend API endpoint
2. Test with different version scenarios
3. Publish app to Play Store
4. Update API with real Play Store URL
5. Monitor update adoption in backend analytics

---

**Note**: The version check only runs once on app launch (splash screen). Users will see the dialog again if they force-close and reopen the app without updating.
