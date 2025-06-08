import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _isLoading = false;
  String _statusMessage = 'Tap "Check Permission" to start';

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    final contactService = GetIt.instance<ContactService>();
    final status = await contactService.getPermissionStatus();
    setState(() {
      _permissionStatus = status;
      _statusMessage = contactService.getPermissionStatusDescription(status);
    });
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting contacts permission...';
    });

    final contactService = GetIt.instance<ContactService>();
    final status = await contactService.requestContactsPermission();

    setState(() {
      _permissionStatus = status;
      _isLoading = false;
      _statusMessage = contactService.getPermissionStatusDescription(status);
    });

    if (status == PermissionStatus.permanentlyDenied) {
      _showSettingsDialog();
    }
  }

  Future<void> _testContactAccess() async {
    if (_permissionStatus != PermissionStatus.granted &&
        _permissionStatus != PermissionStatus.limited) {
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
    if (_permissionStatus != PermissionStatus.granted &&
        _permissionStatus != PermissionStatus.limited) {
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Contacts permission is permanently denied. Please enable it in Settings to save business cards to contacts.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor() {
    switch (_permissionStatus) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.red;
      case PermissionStatus.limited:
        return Colors.yellow;
      case PermissionStatus.provisional:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Contact Permission Test'),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor()),
                      ),
                      child: Text(
                        _permissionStatus.name.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_statusMessage, style: const TextStyle(fontSize: 14)),
                  ],
                ),
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
              onPressed: (_isLoading ||
                      (_permissionStatus != PermissionStatus.granted &&
                          _permissionStatus != PermissionStatus.limited))
                  ? null
                  : _testContactAccess,
              icon: const Icon(Icons.verified_user),
              label: const Text('Test Contact Access'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: (_isLoading ||
                      (_permissionStatus != PermissionStatus.granted &&
                          _permissionStatus != PermissionStatus.limited))
                  ? null
                  : _testAddContact,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Test Contact'),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            const Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to use:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Check permission status to see current state\n'
                        '2. Request permission if needed\n'
                        '3. Test contact access to verify functionality\n'
                        '4. Add a test contact to verify saving works\n'
                        '5. If permission is denied permanently, use Settings button',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
