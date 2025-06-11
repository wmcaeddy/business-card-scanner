import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/business_card.dart';
import '../../services/database_service.dart';
import '../../services/ocr_service.dart';
import 'settings_page.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bcs_container.dart';
import 'camera_page.dart';
import 'business_card_detail_page.dart';
import 'business_card_list_page.dart';
import 'text_mapping_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BusinessCard> _businessCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessCards();
  }

  Future<void> _loadBusinessCards() async {
    try {
      final databaseService = GetIt.instance<DatabaseService>();
      final cards = await databaseService.getAllBusinessCards();
      setState(() {
        _businessCards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load business cards: $e');
    }
  }

  Future<void> _navigateToCamera() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CameraPage()));

    if (result == true) {
      _loadBusinessCards(); // Refresh the list
    }
  }

  Future<void> _captureImage() async {
    final ImagePicker imagePicker = ImagePicker();

    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        await _cropAndNavigate(image.path);
      }
    } catch (e) {
      _showErrorDialog('Failed to capture image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker imagePicker = ImagePicker();

    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _cropAndNavigate(image.path);
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _cropAndNavigate(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Business Card',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio3x2,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Business Card',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
        ],
      );

      if (croppedFile != null) {
        _navigateToDetailWithImage(croppedFile.path);
      }
    } catch (e) {
      _showErrorDialog('Failed to crop image: $e');
      // If cropping fails, use original image
      _navigateToDetailWithImage(imagePath);
    }
  }

  void _navigateToDetailWithImage(String imagePath) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing image...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Extract text from image
      final ocrService = GetIt.instance<OCRService>();
      final textLines = await ocrService.extractTextLines(imagePath);
      final extractedCard = await ocrService.processBusinessCard(imagePath);

      // Close loading dialog
      Navigator.of(context).pop();

      if (textLines.isEmpty) {
        _showErrorDialog('No text found in the image for mapping.');
        return;
      }

      // Navigate directly to mapping page
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TextMappingPage(
            extractedTexts: textLines,
            initialCard: extractedCard.copyWith(imagePath: imagePath),
          ),
        ),
      );

      if (result == true) {
        _loadBusinessCards(); // Refresh the list
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorDialog('Failed to process image: $e');
    }
  }

  void _navigateToSavedCards() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BusinessCardListPage(),
      ),
    );
  }

  void _navigateToDetail(BusinessCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessCardDetailPage(
          imagePath: card.imagePath,
          existingCard: card,
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leadingWidth: 88,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/bcardv1.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
        ),
        backgroundColor: Colors.white,
        title: const Text('BizScan'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'BizScan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Capture and organize your business cards digitally',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Three row action buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _captureImage,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Take Photo'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('From Gallery'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _navigateToSavedCards,
                              icon: const Icon(Icons.folder),
                              label: const Text('Saved Business Cards'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Empty space
                const Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
    );
  }
}
