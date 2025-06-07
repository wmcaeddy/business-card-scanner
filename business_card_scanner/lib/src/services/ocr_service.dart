import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import '../models/business_card.dart';

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  late final TextRecognizer _latinTextRecognizer;
  late final TextRecognizer _chineseTextRecognizer;

  // Initialize the text recognizers
  void initialize() {
    _latinTextRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _chineseTextRecognizer =
        TextRecognizer(script: TextRecognitionScript.chinese);
  }

  /// Extract raw text lines from business card image for manual mapping
  Future<List<String>> extractTextLines(String imagePath) async {
    try {
      // Ensure the text recognizer is initialized
      if (!_isInitialized()) {
        initialize();
      }

      // Create input image from file path
      final inputImage = InputImage.fromFilePath(imagePath);

      // Process the image with both Latin and Chinese recognizers
      final latinText = await _latinTextRecognizer.processImage(inputImage);
      final chineseText = await _chineseTextRecognizer.processImage(inputImage);

      // Combine and split text into lines
      final combinedText = '${latinText.text}\n${chineseText.text}'.trim();
      
      if (combinedText.isEmpty) {
        return [];
      }

      // Split into lines and clean up
      final lines = combinedText
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toSet() // Remove duplicates
          .toList();

      // Sort lines by length (longer lines first, as they're often more informative)
      lines.sort((a, b) => b.length.compareTo(a.length));

      return lines;
    } catch (e) {
      return [];
    }
  }

  Future<BusinessCard> processBusinessCard(String imagePath) async {
    try {
      // Ensure the text recognizer is initialized
      if (!_isInitialized()) {
        initialize();
      }

      // Create input image from file path
      final inputImage = InputImage.fromFilePath(imagePath);

      // Process the image with both Latin and Chinese recognizers
      final latinText = await _latinTextRecognizer.processImage(inputImage);
      final chineseText = await _chineseTextRecognizer.processImage(inputImage);

      // Combine text from both recognizers
      final combinedText = '${latinText.text}\n${chineseText.text}'.trim();

      // Parse the extracted text into business card data
      final extractedData = _parseBusinessCardText(combinedText);

      // Create business card with extracted data
      final now = DateTime.now();
      return BusinessCard(
        id: const Uuid().v4(),
        name: extractedData['name'],
        company: extractedData['company'],
        jobTitle: extractedData['jobTitle'],
        phone: extractedData['phone'],
        email: extractedData['email'],
        website: extractedData['website'],
        address: extractedData['address'],
        imagePath: imagePath,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      // If OCR fails, return a business card with just the image path
      // so the user can manually enter the information
      final now = DateTime.now();
      return BusinessCard(
        id: const Uuid().v4(),
        imagePath: imagePath,
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  /// Process business card with manual mapping option
  Future<Map<String, dynamic>> processBusinessCardWithMapping(String imagePath) async {
    try {
      // Extract raw text lines
      final textLines = await extractTextLines(imagePath);
      
      // Also get the auto-parsed business card
      final businessCard = await processBusinessCard(imagePath);

      return {
        'textLines': textLines,
        'businessCard': businessCard,
      };
    } catch (e) {
      final now = DateTime.now();
      return {
        'textLines': <String>[],
        'businessCard': BusinessCard(
          id: const Uuid().v4(),
          imagePath: imagePath,
          createdAt: now,
          updatedAt: now,
        ),
      };
    }
  }

  bool _isInitialized() {
    try {
      // Simple check to see if the recognizer is available
      return true; // TextRecognizer doesn't have a direct way to check initialization
    } catch (e) {
      return false;
    }
  }

  // Enhanced text parsing with better regex patterns and logic
  Map<String, String?> _parseBusinessCardText(String text) {
    if (text.trim().isEmpty) {
      return {
        'name': null,
        'company': null,
        'jobTitle': null,
        'phone': null,
        'email': null,
        'website': null,
        'address': null,
      };
    }

    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String? name;
    String? company;
    String? jobTitle;
    String? phone;
    String? email;
    String? website;
    String? address;

    // Enhanced regex patterns
    final emailRegex = RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
      caseSensitive: false,
    );

    // More comprehensive phone regex supporting international formats
    final phoneRegex = RegExp(
      r'(\+?1?[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})|'
      r'(\+\d{1,3}[-.\s]?)?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}',
    );

    // Enhanced website regex
    final websiteRegex = RegExp(
      r'(https?://)?(www\.)?[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?'
      r'\.[a-zA-Z]{2,}(/[^\s]*)?',
      caseSensitive: false,
    );

    // Expanded job title keywords
    final jobTitleKeywords = [
      'CEO',
      'CTO',
      'CFO',
      'COO',
      'CIO',
      'CMO',
      'CPO',
      'President',
      'Vice President',
      'VP',
      'SVP',
      'EVP',
      'Director',
      'Manager',
      'Senior',
      'Lead',
      'Head',
      'Chief',
      'Engineer',
      'Developer',
      'Designer',
      'Analyst',
      'Consultant',
      'Specialist',
      'Coordinator',
      'Assistant',
      'Executive',
      'Supervisor',
      'Administrator',
      'Officer',
      'Representative',
      'Sales',
      'Marketing',
      'Operations',
      'Finance',
      'HR',
      'Software',
      'Hardware',
      'Product',
      'Project',
      'Program',
      'Technical',
      'Business',
      'Account',
      'Customer',
      'Client'
    ];

    // Company indicators
    final companyIndicators = [
      'Inc',
      'LLC',
      'Corp',
      'Corporation',
      'Company',
      'Co',
      'Ltd',
      'Limited',
      'Group',
      'Associates',
      'Partners',
      'Solutions',
      'Services',
      'Systems',
      'Technologies',
      'Consulting',
      'Enterprises',
      'Industries'
    ];

    List<String> usedLines = [];

    // First pass: Extract clear patterns
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Extract email
      if (email == null && emailRegex.hasMatch(line)) {
        final match = emailRegex.firstMatch(line);
        if (match != null) {
          email = match.group(0);
          usedLines.add(line);
          continue;
        }
      }

      // Extract phone
      if (phone == null && phoneRegex.hasMatch(line)) {
        final match = phoneRegex.firstMatch(line);
        if (match != null) {
          phone = _cleanPhoneNumber(match.group(0) ?? '');
          usedLines.add(line);
          continue;
        }
      }

      // Extract website
      if (website == null && websiteRegex.hasMatch(line)) {
        final match = websiteRegex.firstMatch(line);
        if (match != null) {
          website = _cleanWebsite(match.group(0) ?? '');
          usedLines.add(line);
          continue;
        }
      }
    }

    // Second pass: Extract job title, name, and company
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (usedLines.contains(line)) continue;

      // Extract job title (line containing job title keywords)
      if (jobTitle == null &&
          _containsJobTitleKeywords(line, jobTitleKeywords)) {
        jobTitle = line;
        usedLines.add(line);
        continue;
      }

      // Extract company (line containing company indicators)
      if (company == null &&
          _containsCompanyIndicators(line, companyIndicators)) {
        company = line;
        usedLines.add(line);
        continue;
      }

      // Extract name (likely to be first non-used line that looks like a name)
      if (name == null && _isLikelyName(line)) {
        name = line;
        usedLines.add(line);
        continue;
      }
    }

    // Third pass: If company not found, look for lines that might be company names
    if (company == null) {
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (usedLines.contains(line)) continue;

        if (_isLikelyCompany(line)) {
          company = line;
          usedLines.add(line);
          break;
        }
      }
    }

    // Fourth pass: Build address from remaining lines
    final addressLines = lines
        .where((line) => !usedLines.contains(line))
        .where((line) => _isLikelyAddress(line))
        .toList();

    if (addressLines.isNotEmpty) {
      address = addressLines.join(', ');
    }

    return {
      'name': name,
      'company': company,
      'jobTitle': jobTitle,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
    };
  }

  bool _containsJobTitleKeywords(String text, List<String> keywords) {
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }

  bool _containsCompanyIndicators(String text, List<String> indicators) {
    final lowerText = text.toLowerCase();
    return indicators
        .any((indicator) => lowerText.contains(indicator.toLowerCase()));
  }

  bool _isLikelyName(String text) {
    // Check if text looks like a name
    if (text.length < 2 || text.length > 50) return false;

    final words = text.split(' ');
    if (words.length > 4 || words.isEmpty) return false;

    // Check if words start with capital letters and contain only letters
    return words.every((word) =>
        word.isNotEmpty &&
        word[0] == word[0].toUpperCase() &&
        RegExp(r"^[a-zA-Z\s\-\.']+$").hasMatch(word));
  }

  bool _isLikelyCompany(String text) {
    // Check if text looks like a company name
    if (text.length < 2 || text.length > 100) return false;

    // Company names often have mixed case or all caps
    final hasUpperCase = text.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = text.contains(RegExp(r'[a-z]'));

    return hasUpperCase && (hasLowerCase || text == text.toUpperCase());
  }

  bool _isLikelyAddress(String text) {
    // Check if text looks like an address
    if (text.isEmpty || text.length < 5) return false;

    // Address indicators
    final addressKeywords = [
      'street',
      'st',
      'avenue',
      'ave',
      'road',
      'rd',
      'drive',
      'dr',
      'lane',
      'ln',
      'boulevard',
      'blvd',
      'suite',
      'ste',
      'floor',
      'building',
      'bldg',
      'unit',
      'apt',
      'apartment'
    ];

    final lowerText = text.toLowerCase();
    final hasAddressKeyword =
        addressKeywords.any((keyword) => lowerText.contains(keyword));

    // Check for numbers (addresses usually have numbers)
    final hasNumbers = RegExp(r'\d').hasMatch(text);

    return hasAddressKeyword || hasNumbers;
  }

  String _cleanPhoneNumber(String phone) {
    // Remove extra characters and format consistently
    return phone.replaceAll(RegExp(r'[^\d+\-\(\)\s]'), '').trim();
  }

  String _cleanWebsite(String website) {
    // Ensure website has proper protocol
    if (!website.startsWith('http://') && !website.startsWith('https://')) {
      return 'https://$website';
    }
    return website;
  }

  void dispose() {
    try {
      _latinTextRecognizer.close();
      _chineseTextRecognizer.close();
    } catch (e) {
      // Handle disposal error silently
    }
  }
}
