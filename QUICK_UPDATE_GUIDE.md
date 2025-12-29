# Quick Update Guide

## 🚀 How to Release a New Version (2 Simple Steps)

### Step 1️⃣: Update App Version

File: `pubspec.yaml`
```yaml
version: 1.0.4+10  # ← Change this line
```

### Step 2️⃣: Update Force Update Settings

File: `lib/services/version_check_service.dart`

Find this section at the top of the file:

```dart
// ========== CONFIGURATION - UPDATE THESE VALUES ==========

/// Latest version available on Play Store
static const String latestVersion = '1.0.4';  // ← Update this

/// Minimum version required
static const String minRequiredVersion = '1.0.3';  // ← Update this

/// Enable force update
static const bool enableForceUpdate = true;  // ← true or false

/// Update message
static const String updateMessage = 
    'Update message here';  // ← Customize this

// Play Store URL (update after publishing)
static const String androidUrl = 
    'https://play.google.com/store/apps/details?id=com.navyugdigital.userapp';
```

---

## 📋 Common Scenarios

### Scenario 1: Regular Update (Users Can Skip)
```dart
latestVersion = '1.0.4'          // Your new version
minRequiredVersion = '1.0.3'     // Still allow 1.0.3
enableForceUpdate = false        // Optional update
```

### Scenario 2: Force Update (Users MUST Update)
```dart
latestVersion = '1.0.4'          // Your new version
minRequiredVersion = '1.0.4'     // Everyone must have 1.0.4
enableForceUpdate = true         // Force update
```

### Scenario 3: Critical Bug Fix
```dart
latestVersion = '1.0.4'          // Bug fix version
minRequiredVersion = '1.0.4'     // Block old versions
enableForceUpdate = true         // Must update
updateMessage = 'Critical security update required!'
```

---

## ⚡ That's It!

No backend, no API, just update these two files and build! 🎉

**Read full documentation**: See `FORCE_UPDATE_GUIDE.md` for detailed instructions.
