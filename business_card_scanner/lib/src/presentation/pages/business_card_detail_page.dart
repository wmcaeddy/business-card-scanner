import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/business_card.dart';
import '../../services/ocr_service.dart';
import '../../services/database_service.dart';
import '../../services/contact_service.dart';

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

  bool _isProcessing = false;
  bool _isSaving = false;
  BusinessCard? _businessCard;

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      _populateFields(widget.existingCard!);
    } else {
      _processImage();
    }
  }

  void _populateFields(BusinessCard card) {
    _nameController.text = card.name ?? '';
    _companyController.text = card.company ?? '';
    _jobTitleController.text = card.jobTitle ?? '';
    _phoneController.text = card.phone ?? '';
    _emailController.text = card.email ?? '';
    _websiteController.text = card.website ?? '';
    _addressController.text = card.address ?? '';
    _notesController.text = card.notes ?? '';
    _businessCard = card;
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final ocrService = GetIt.instance<OCRService>();
      final extractedCard = await ocrService.processBusinessCard(
        widget.imagePath,
      );

      setState(() {
        _businessCard = extractedCard;
        _populateFields(extractedCard);
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Failed to process business card: $e');
    }
  }

  Future<void> _saveBusinessCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
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
        createdAt: _businessCard?.createdAt ?? now,
        updatedAt: now,
      );

      final databaseService = GetIt.instance<DatabaseService>();
      await databaseService.insertBusinessCard(updatedCard);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business card saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorDialog('Failed to save business card: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _addToContacts() async {
    if (_businessCard == null) return;

    try {
      final contactService = GetIt.instance<ContactService>();
      await contactService.addToContacts(_businessCard!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to contacts successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to add to contacts: $e');
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
          if (_businessCard != null)
            IconButton(
              onPressed: _addToContacts,
              icon: const Icon(Icons.person_add),
              tooltip: 'Add to Contacts',
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing business card...'),
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
