import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/business_card.dart';
import '../../services/ocr_service.dart';
import '../../services/database_service.dart';
import '../../services/contact_service.dart';
import '../../services/export_service.dart';
import 'text_mapping_page.dart';

class BusinessCardDetailPage extends StatefulWidget {
  final String imagePath;
  final BusinessCard? existingCard;

  const BusinessCardDetailPage({
    super.key,
    required this.imagePath,
    this.existingCard,
  });

  @override
  State<BusinessCardDetailPage> createState() => _BusinessCardDetailPageState();
}

class _BusinessCardDetailPageState extends State<BusinessCardDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  BusinessCard? _businessCard;

  bool _isProcessing = false;
  bool _isSaving = false;
  bool _isAddingToContacts = false;
  bool _isExporting = false;
  String _processingStatus = '';

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      _businessCard = widget.existingCard;
      _populateFields();
    } else {
      _processImage();
    }
  }

  void _populateFields() {
    if (_businessCard != null) {
      _nameController.text = _businessCard!.name ?? '';
      _companyController.text = _businessCard!.company ?? '';
      _jobTitleController.text = _businessCard!.jobTitle ?? '';
      _phoneController.text = _businessCard!.phone ?? '';
      _emailController.text = _businessCard!.email ?? '';
      _websiteController.text = _businessCard!.website ?? '';
      _addressController.text = _businessCard!.address ?? '';
      _notesController.text = _businessCard!.notes ?? '';
    }
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
      _processingStatus = 'Analyzing image...';
    });

    try {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Small delay for UX

      setState(() {
        _processingStatus = 'Extracting text...';
      });

      final ocrService = GetIt.instance<OCRService>();
      final extractedCard = await ocrService.processBusinessCard(
        widget.imagePath,
      );

      setState(() {
        _processingStatus = 'Processing information...';
      });

      await Future.delayed(
          const Duration(milliseconds: 300)); // Small delay for UX

      setState(() {
        _businessCard = extractedCard;
        _isProcessing = false;
        _processingStatus = '';
      });

      _populateFields();

      // Show success message with mapping option
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Business card processed! Tap to adjust field mapping.')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Map Fields',
              textColor: Colors.white,
              onPressed: _showTextMapping,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _processingStatus = '';
      });
      _showErrorDialog('Failed to process business card: $e');
    }
  }

  Future<void> _showTextMapping() async {
    try {
      final ocrService = GetIt.instance<OCRService>();
      final textLines = await ocrService.extractTextLines(widget.imagePath);
      
      if (textLines.isEmpty) {
        _showErrorDialog('No text found in the image for mapping.');
        return;
      }

      final result = await Navigator.of(context).push<BusinessCard>(
        MaterialPageRoute(
          builder: (context) => TextMappingPage(
            extractedTexts: textLines,
            initialCard: _businessCard,
          ),
        ),
      );

      if (result != null) {
        setState(() {
          _businessCard = result;
        });
        _populateFields();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Field mapping updated successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to load text mapping: $e');
    }
  }

  Future<void> _saveBusinessCard() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedCard = BusinessCard(
        id: _businessCard?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        jobTitle: _jobTitleController.text.trim().isEmpty
            ? null
            : _jobTitleController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        imagePath: widget.imagePath,
        createdAt: _businessCard?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final databaseService = GetIt.instance<DatabaseService>();
      await databaseService.insertBusinessCard(updatedCard);

      setState(() {
        _businessCard = updatedCard;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.save, color: Colors.white),
                SizedBox(width: 8),
                Text('Business card saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorDialog('Failed to save business card: $e');
    }
  }

  Future<void> _addToContacts() async {
    if (_businessCard == null) return;

    setState(() {
      _isAddingToContacts = true;
    });

    try {
      final contactService = GetIt.instance<ContactService>();
      
      // First test contacts access
      final canAccess = await contactService.testContactsAccess();
      if (!canAccess) {
        setState(() {
          _isAddingToContacts = false;
        });
        _showContactsPermissionDialog();
        return;
      }

      // Add to contacts
      await contactService.addToContacts(_businessCard!);

      setState(() {
        _isAddingToContacts = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.person_add, color: Colors.white),
                SizedBox(width: 8),
                Text('Added to contacts successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAddingToContacts = false;
      });
      
      // Show more specific error handling
      if (e.toString().contains('permission')) {
        _showContactsPermissionDialog();
      } else {
        _showErrorDialog('Failed to add to contacts: $e');
      }
    }
  }

  void _showContactsPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacts Permission Required'),
        content: const Text(
          'This app needs permission to access your contacts to save business card information. '
          'Please grant contacts permission in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final contactService = GetIt.instance<ContactService>();
              await contactService.requestContactsPermission();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAsVCard() async {
    if (_businessCard == null) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final exportService = GetIt.instance<ExportService>();
      final filePath = await exportService.exportSingleVCard(_businessCard!);

      setState(() {
        _isExporting = false;
      });

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.download, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Exported to: ${filePath.split('/').last}'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Could implement file viewer here
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      _showErrorDialog('Failed to export vCard: $e');
    }
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
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Card Details'),
        actions: [
          if (_businessCard != null) ...[
            IconButton(
              onPressed: _showTextMapping,
              icon: const Icon(Icons.tune),
              tooltip: 'Map Text Fields',
            ),
            IconButton(
              onPressed: _isExporting ? null : _exportAsVCard,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              tooltip: 'Export vCard',
            ),
            IconButton(
              onPressed: _isAddingToContacts ? null : _addToContacts,
              icon: _isAddingToContacts
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add),
              tooltip: 'Add to Contacts',
            ),
          ],
        ],
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(strokeWidth: 3),
                  const SizedBox(height: 24),
                  Text(
                    _processingStatus,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please wait while we analyze your business card',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Business card image
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form fields
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _companyController,
                      label: 'Company',
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _jobTitleController,
                      label: 'Job Title',
                      icon: Icons.work,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _websiteController,
                      label: 'Website',
                      icon: Icons.language,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _notesController,
                      label: 'Notes',
                      icon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveBusinessCard,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Business Card',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
