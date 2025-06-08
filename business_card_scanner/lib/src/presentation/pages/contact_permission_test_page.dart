import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../services/contact_service.dart';
import '../../models/business_card.dart';

class ContactPermissionTestPage extends StatefulWidget {
  const ContactPermissionTestPage({super.key});

  @override
  State<ContactPermissionTestPage> createState() =>
      _ContactPermissionTestPageState();
}

class _ContactPermissionTestPageState extends State<ContactPermissionTestPage> {
  bool _hasPermission = false;
  bool _isLoading = false;
  String _statusMessage = 'Tap "Check Permission" to start';

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    final contactService = GetIt.instance<ContactService>();
    final hasPermission = await contactService.hasContactsPermission();
    setState(() {
      _hasPermission = hasPermission;
      _statusMessage =
          contactService.getPermissionStatusDescription(hasPermission);
    });
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting contacts permission...';
    });

    final contactService = GetIt.instance<ContactService>();
    final hasPermission = await contactService.requestContactsPermission();

    setState(() {
      _hasPermission = hasPermission;
      _isLoading = false;
      _statusMessage =
          contactService.getPermissionStatusDescription(hasPermission);
    });

    if (!hasPermission) {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _testContactAccess() async {
    if (!_hasPermission) {
      setState(() {
        _statusMessage = 'Permission not granted. Cannot test contact access.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing contact access...';
    });

    try {
      final contactService = GetIt.instance<ContactService>();
      final canAccess = await contactService.testContactsAccess();

      setState(() {
        _isLoading = false;
        _statusMessage = canAccess
            ? 'Contact access test successful! You can save business cards to contacts.'
            : 'Contact access test failed. Please check permissions.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Contact access test failed: $e';
      });
    }
  }

  Future<void> _testAddContact() async {
    if (!_hasPermission) {
      setState(() {
        _statusMessage = 'Permission not granted. Cannot add test contact.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Adding test contact...';
    });

    try {
      final contactService = GetIt.instance<ContactService>();

      // Create a test business card
      final testCard = BusinessCard(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Contact',
        company: 'Business Card Scanner',
        jobTitle: 'Test Contact',
        phone: '+1234567890',
        email: 'test@example.com',
        address: '123 Test Street, Test City',
        notes: 'This is a test contact created by Business Card Scanner',
        imagePath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await contactService.addToContacts(testCard);

      setState(() {
        _isLoading = false;
        _statusMessage =
            'Test contact added successfully! Check your contacts app.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Failed to add test contact: $e';
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Contacts permission is required to save business cards to contacts. Please grant permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor() {
    if (_hasPermission) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Permission Test'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permission Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _hasPermission ? Icons.check_circle : Icons.warning,
                          color: _getStatusColor(),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Test Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkPermissionStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Check Permission Status'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _requestPermission,
              icon: const Icon(Icons.contact_phone),
              label: const Text('Request Contacts Permission'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed:
                  (_isLoading || !_hasPermission) ? null : _testContactAccess,
              icon: const Icon(Icons.verified_user),
              label: const Text('Test Contact Access'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed:
                  (_isLoading || !_hasPermission) ? null : _testAddContact,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Test Contact'),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            const Spacer(),
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About This Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This page helps you test contact permissions for the Business Card Scanner app. '
                      'The app uses flutter_contacts for better iOS and Android compatibility.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
