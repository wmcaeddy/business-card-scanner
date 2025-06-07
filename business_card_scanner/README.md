# Business Card Scanner

A Flutter mobile application that allows users to scan business cards using their device camera, extract text information using OCR (Optical Character Recognition), and save the contact details to their device.

## Features

### ✅ Implemented Features
- **Camera Integration**: Capture business card images using device camera
- **Gallery Selection**: Pick business card images from photo gallery
- **OCR Text Recognition**: Extract text from business card images using Google ML Kit
- **Smart Field Parsing**: Automatically parse and categorize extracted text into:
  - Name
  - Company
  - Job Title
  - Phone Number
  - Email Address
  - Website
  - Address
- **Local Storage**: Save business cards to local SQLite database
- **Contact Export**: Add business card information to device contacts
- **Search & Filter**: Search through saved business cards
- **Edit & Delete**: Modify or remove saved business cards
- **Modern UI**: Clean, intuitive user interface with Material Design

### 📱 iOS Support
- ✅ Camera permissions configured
- ✅ Photo library permissions configured
- ✅ Contacts permissions configured
- ✅ iOS-specific dependencies included
- ✅ Proper iOS build configuration

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.3.4)
- iOS development environment (Xcode, iOS Simulator)
- Physical iOS device for camera testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd business-card-scanner
   ```

2. **Navigate to the app directory**
   ```bash
   cd business_card_scanner
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### iOS-Specific Setup

The app is already configured with the necessary iOS permissions in `ios/Runner/Info.plist`:
- Camera access permission
- Photo library access permission
- Contacts access permission

### Dependencies

The app uses the following key packages:
- `camera`: Camera functionality
- `image_picker`: Gallery image selection
- `google_mlkit_text_recognition`: OCR text extraction
- `sqflite`: Local database storage
- `contacts_service`: Device contacts integration
- `permission_handler`: Runtime permissions
- `image_cropper`: Image editing capabilities

## Usage

1. **Scan a Business Card**
   - Tap the "Scan New Card" button or camera FAB
   - Point camera at business card and capture
   - Or select an image from gallery

2. **Review & Edit**
   - Review automatically extracted information
   - Edit any fields as needed
   - Add notes if desired

3. **Save**
   - Tap "Save Business Card" to store locally
   - Optionally add to device contacts

4. **Manage Cards**
   - View all saved cards on home screen
   - Search through cards using the search bar
   - Edit or delete cards as needed

## Architecture

The app follows a clean architecture pattern with:
- **Presentation Layer**: UI components and pages
- **Service Layer**: Business logic and external integrations
- **Data Layer**: Local storage and data models
- **Modular Structure**: Core and settings packages

## File Structure

```
lib/
├── src/
│   ├── models/
│   │   └── business_card.dart
│   ├── services/
│   │   ├── database_service.dart
│   │   ├── ocr_service.dart
│   │   └── contact_service.dart
│   └── presentation/
│       ├── pages/
│       │   ├── home_page.dart
│       │   ├── camera_page.dart
│       │   ├── business_card_detail_page.dart
│       │   └── business_card_list_page.dart
│       └── widgets/
packages/
├── core/           # Core utilities and shared components
└── settings/       # Settings management
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on iOS devices
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Melos
Project uses Melos for managing packages. Run the command below to see available actions:
```bash
melos -h
```

## Mocks
To generate mocks, run the following command:
```bash
dart run build_runner build --delete-conflicting-outputs  
```

To generate mocks for packages, run the following command:
```bash
melos generate
```

## Tests
To run main project tests, run the following command:
```bash
flutter test
```

To run tests for packages, run the following command:
```bash
melos test
```
