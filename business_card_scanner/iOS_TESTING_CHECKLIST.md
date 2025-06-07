# iOS Testing Checklist for Business Card Scanner

## 🔧 **Pre-Testing Setup**

### 1. **iOS Configuration Verification**
- [ ] **Info.plist permissions** are correctly configured:
  - [ ] `NSCameraUsageDescription` - Camera access for scanning
  - [ ] `NSPhotoLibraryUsageDescription` - Photo library access for selecting images
  - [ ] `NSPhotoLibraryAddUsageDescription` - Photo library access for saving images
  - [ ] `NSContactsUsageDescription` - Contacts access for saving business cards
- [ ] **Bundle identifier** is properly set
- [ ] **App display name** is "Business Card Scanner"
- [ ] **Minimum iOS version** compatibility (iOS 12.0+)

### 2. **Dependencies Installation**
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

## 📱 **Core Functionality Testing**

### 3. **Camera & Image Capture**
- [ ] **Camera permission** request appears on first launch
- [ ] **Camera opens** successfully from main screen
- [ ] **Take photo** functionality works
- [ ] **Gallery selection** works (photo library permission)
- [ ] **Image cropping** interface appears after image selection
- [ ] **Crop functionality** works correctly
- [ ] **Navigation** to detail page after cropping

### 4. **OCR Text Recognition**
- [ ] **Google ML Kit** initializes correctly on iOS
- [ ] **Text extraction** works from business card images
- [ ] **Processing indicators** show during OCR
- [ ] **Text parsing** correctly identifies:
  - [ ] Names
  - [ ] Company names
  - [ ] Job titles
  - [ ] Phone numbers (various formats)
  - [ ] Email addresses
  - [ ] Websites
  - [ ] Addresses
- [ ] **Error handling** for failed OCR processing

### 5. **Data Persistence (SQLite)**
- [ ] **Database creation** works on iOS
- [ ] **Business card saving** persists data
- [ ] **Data retrieval** works correctly
- [ ] **Search functionality** works
- [ ] **Edit/Update** business cards
- [ ] **Delete** business cards
- [ ] **App restart** maintains saved data

### 6. **Contacts Integration**
- [ ] **Contacts permission** request appears
- [ ] **Add to Contacts** button works
- [ ] **Contact creation** with all available fields:
  - [ ] Name (first/last)
  - [ ] Company
  - [ ] Job title
  - [ ] Phone number
  - [ ] Email address
  - [ ] Address
- [ ] **Contacts app** shows newly added contact
- [ ] **Error handling** for permission denial

### 7. **Export Functionality**
- [ ] **Storage permission** handling (iOS document directory)
- [ ] **CSV export** creates valid file
- [ ] **vCard export** creates valid .vcf file
- [ ] **Single card export** works
- [ ] **Bulk export** works
- [ ] **File location** accessible in Files app
- [ ] **Export notifications** show file path

## 🎨 **User Experience Testing**

### 8. **UI/UX Elements**
- [ ] **Loading indicators** during processing
- [ ] **Progress messages** during OCR
- [ ] **Success notifications** with icons
- [ ] **Error dialogs** with clear messages
- [ ] **Pull-to-refresh** on home screen
- [ ] **Search functionality** in business card list
- [ ] **Settings page** accessible and functional
- [ ] **App drawer** navigation works

### 9. **Navigation & Flow**
- [ ] **Home screen** → Camera → Detail → Save flow
- [ ] **Business card list** navigation
- [ ] **Edit existing cards** flow
- [ ] **Settings page** navigation
- [ ] **Back navigation** works correctly
- [ ] **App state preservation** during navigation

### 10. **Performance Testing**
- [ ] **App launch time** is reasonable
- [ ] **OCR processing time** is acceptable
- [ ] **Image loading** is smooth
- [ ] **Database operations** are fast
- [ ] **Memory usage** is reasonable
- [ ] **No crashes** during normal usage

## 🔍 **Edge Cases & Error Handling**

### 11. **Permission Scenarios**
- [ ] **Camera permission denied** - shows appropriate message
- [ ] **Photo library permission denied** - graceful fallback
- [ ] **Contacts permission denied** - clear error message
- [ ] **Storage permission issues** - export error handling

### 12. **Network & Storage**
- [ ] **Low storage** scenarios
- [ ] **Large image files** handling
- [ ] **Poor quality images** OCR handling
- [ ] **Empty/blank images** error handling
- [ ] **Corrupted image files** error handling

### 13. **Data Validation**
- [ ] **Empty business card** saving
- [ ] **Invalid email formats** handling
- [ ] **Invalid phone numbers** handling
- [ ] **Special characters** in text fields
- [ ] **Very long text** handling

## 📊 **Data Integrity Testing**

### 14. **Database Operations**
- [ ] **Concurrent operations** handling
- [ ] **Database migration** (if applicable)
- [ ] **Data backup/restore** functionality
- [ ] **Clear all data** works correctly
- [ ] **Database corruption** recovery

### 15. **Export Data Validation**
- [ ] **CSV format** is valid and readable
- [ ] **vCard format** is standard compliant
- [ ] **Special characters** in exports
- [ ] **Unicode text** handling
- [ ] **File encoding** is correct

## 🚀 **iOS-Specific Features**

### 16. **iOS Integration**
- [ ] **Files app** integration for exports
- [ ] **Share sheet** functionality (if implemented)
- [ ] **Background app refresh** handling
- [ ] **iOS notifications** (if applicable)
- [ ] **Dark mode** compatibility
- [ ] **Dynamic type** support
- [ ] **Accessibility** features

### 17. **Device Testing**
- [ ] **iPhone** (various screen sizes)
- [ ] **iPad** compatibility
- [ ] **Different iOS versions** (12.0+)
- [ ] **Device rotation** handling
- [ ] **Memory-constrained devices**

## ✅ **Final Verification**

### 18. **Complete User Journey**
1. [ ] **Install app** → Grant permissions
2. [ ] **Scan first business card** → Crop → Edit → Save
3. [ ] **Add to contacts** → Verify in Contacts app
4. [ ] **Scan multiple cards** → Build library
5. [ ] **Search cards** → Find specific card
6. [ ] **Export data** → Verify files in Files app
7. [ ] **Edit existing card** → Update information
8. [ ] **Delete card** → Confirm removal
9. [ ] **App settings** → Clear all data → Confirm

### 19. **Production Readiness**
- [ ] **No debug logs** in release build
- [ ] **App Store guidelines** compliance
- [ ] **Privacy policy** considerations
- [ ] **Performance benchmarks** met
- [ ] **Crash reporting** (if implemented)

## 🐛 **Known iOS-Specific Issues to Watch For**

1. **ML Kit Text Recognition**
   - May require additional iOS-specific configuration
   - Performance varies on older devices

2. **Image Cropper**
   - iOS-specific UI differences
   - Permission handling variations

3. **Contacts Integration**
   - iOS contacts framework differences
   - Privacy restrictions

4. **File System Access**
   - iOS sandbox limitations
   - Document directory permissions

5. **Camera Integration**
   - iOS camera permission flow
   - Hardware-specific issues

## 📝 **Testing Notes Template**

```
Device: [iPhone/iPad model]
iOS Version: [Version number]
App Version: [Version number]
Date: [Testing date]

Test Results:
- ✅ Feature working correctly
- ⚠️ Feature working with minor issues
- ❌ Feature not working
- 📝 Additional notes

Issues Found:
1. [Description of issue]
2. [Steps to reproduce]
3. [Expected vs actual behavior]
```

## 🎯 **Priority Testing Order**

1. **High Priority**: Camera, OCR, Data persistence
2. **Medium Priority**: Contacts integration, Export functionality
3. **Low Priority**: UI polish, Settings, Edge cases

This checklist ensures comprehensive testing of all implemented features specifically for iOS deployment. 