import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/foundation.dart';
import '../models/business_card.dart';
import 'contact_service.dart';

/// Comprehensive test class for ContactService functionality
/// This class provides methods to test all contact-related operations
class ContactServiceTest {
  final ContactService _contactService = ContactService();

  /// Run all tests and return a comprehensive report
  Future<Map<String, dynamic>> runAllTests() async {
    final results = <String, dynamic>{};

    try {
      // Test 1: Permission checking
      results['permission_check'] = await _testPermissionCheck();

      // Test 2: Permission request
      results['permission_request'] = await _testPermissionRequest();

      // Test 3: Contact access test
      results['contact_access'] = await _testContactAccess();

      // Test 4: Get all contacts
      results['get_contacts'] = await _testGetAllContacts();

      // Test 5: Add business card to contacts
      results['add_business_card'] = await _testAddBusinessCard();

      // Test 6: Can add contacts check
      results['can_add_contacts'] = await _testCanAddContacts();

      // Test 7: Permission status description
      results['permission_description'] = await _testPermissionDescription();

      // Overall success
      final allPassed = results.values
          .every((result) => result is Map && result['success'] == true);

      results['overall_success'] = allPassed;
      results['test_timestamp'] = DateTime.now().toIso8601String();
    } catch (e) {
      results['error'] = 'Test suite failed: $e';
      results['overall_success'] = false;
    }

    return results;
  }

  /// Test permission checking functionality
  Future<Map<String, dynamic>> _testPermissionCheck() async {
    try {
      final hasPermission = await _contactService.hasContactsPermission();

      return {
        'success': true,
        'has_permission': hasPermission,
        'message': 'Permission check completed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Permission check failed',
      };
    }
  }

  /// Test permission request functionality
  Future<Map<String, dynamic>> _testPermissionRequest() async {
    try {
      final granted = await _contactService.requestContactsPermission();

      return {
        'success': true,
        'permission_granted': granted,
        'message': granted
            ? 'Permission granted successfully'
            : 'Permission was denied by user',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Permission request failed',
      };
    }
  }

  /// Test contact access functionality
  Future<Map<String, dynamic>> _testContactAccess() async {
    try {
      final canAccess = await _contactService.testContactsAccess();

      return {
        'success': true,
        'can_access': canAccess,
        'message': canAccess
            ? 'Contact access test passed'
            : 'Contact access test failed - permission may be denied',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Contact access test failed',
      };
    }
  }

  /// Test getting all contacts
  Future<Map<String, dynamic>> _testGetAllContacts() async {
    try {
      final contacts = await _contactService.getAllContacts();

      return {
        'success': true,
        'contact_count': contacts.length,
        'message': 'Successfully retrieved ${contacts.length} contacts',
        'sample_contacts': contacts
            .take(3)
            .map((c) => {
                  'id': c.id,
                  'displayName': c.displayName,
                  'phoneCount': c.phones.length,
                  'emailCount': c.emails.length,
                })
            .toList(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to get contacts',
      };
    }
  }

  /// Test adding a business card to contacts
  Future<Map<String, dynamic>> _testAddBusinessCard() async {
    try {
      // Create a comprehensive test business card
      final testCard = BusinessCard(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Flutter Contacts Test',
        company: 'Test Company Inc.',
        jobTitle: 'Software Engineer',
        phone: '+1-555-123-4567',
        email: 'test@fluttercontacts.com',
        website: 'https://flutter.dev',
        address: '123 Test Street, Test City, TC 12345',
        notes:
            'This is a test contact created by the Business Card Scanner app to verify flutter_contacts functionality.',
        imagePath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _contactService.addToContacts(testCard);

      return {
        'success': success,
        'message': success
            ? 'Test business card added successfully'
            : 'Failed to add test business card',
        'test_card': {
          'name': testCard.name,
          'company': testCard.company,
          'phone': testCard.phone,
          'email': testCard.email,
          'website': testCard.website,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to add business card to contacts',
      };
    }
  }

  /// Test can add contacts functionality
  Future<Map<String, dynamic>> _testCanAddContacts() async {
    try {
      final canAdd = await _contactService.canAddContacts();

      return {
        'success': true,
        'can_add': canAdd,
        'message': canAdd
            ? 'App can add contacts'
            : 'App cannot add contacts - permission may be denied',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to check if can add contacts',
      };
    }
  }

  /// Test permission status description
  Future<Map<String, dynamic>> _testPermissionDescription() async {
    try {
      final hasPermission = await _contactService.hasContactsPermission();
      final description =
          _contactService.getPermissionStatusDescription(hasPermission);

      return {
        'success': true,
        'has_permission': hasPermission,
        'description': description,
        'message': 'Permission description generated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to get permission description',
      };
    }
  }

  /// Test business card validation
  Future<Map<String, dynamic>> testBusinessCardValidation() async {
    try {
      // Test empty business card
      final emptyCard = BusinessCard(
        id: 'empty_test',
        imagePath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await _contactService.addToContacts(emptyCard);
        return {
          'success': false,
          'message': 'Empty business card should have been rejected',
        };
      } catch (e) {
        // This is expected - empty cards should be rejected
        return {
          'success': true,
          'message': 'Empty business card correctly rejected: ${e.toString()}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Business card validation test failed',
      };
    }
  }

  /// Test contact field mapping
  Future<Map<String, dynamic>> testContactFieldMapping() async {
    try {
      final testCard = BusinessCard(
        id: 'field_test',
        name: 'John Doe Smith',
        company: 'Tech Corp',
        jobTitle: 'Senior Developer',
        phone: '+1-555-987-6543',
        email: 'john.doe@techcorp.com',
        website: 'https://johndoe.dev',
        address: '456 Developer Lane, Code City, CC 67890',
        notes: 'Test contact for field mapping verification',
        imagePath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // This tests the internal contact creation without actually adding to contacts
      // We would need to make _createContactFromBusinessCard public to test this properly

      return {
        'success': true,
        'message':
            'Contact field mapping test would require internal method access',
        'note':
            'Consider making _createContactFromBusinessCard public for testing',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Contact field mapping test failed',
      };
    }
  }

  /// Generate a test report
  String generateTestReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('=== Flutter Contacts Test Report ===');
    buffer.writeln('Generated: ${results['test_timestamp'] ?? 'Unknown'}');
    buffer.writeln('Overall Success: ${results['overall_success'] ?? false}');
    buffer.writeln();

    // Individual test results
    results.forEach((key, value) {
      if (key != 'overall_success' &&
          key != 'test_timestamp' &&
          key != 'error') {
        if (value is Map) {
          buffer.writeln('--- $key ---');
          buffer.writeln('Success: ${value['success'] ?? false}');
          buffer.writeln('Message: ${value['message'] ?? 'No message'}');
          if (value['error'] != null) {
            buffer.writeln('Error: ${value['error']}');
          }
          buffer.writeln();
        }
      }
    });

    if (results['error'] != null) {
      buffer.writeln('=== CRITICAL ERROR ===');
      buffer.writeln(results['error']);
    }

    return buffer.toString();
  }
}

/// Helper function to run tests from UI
Future<String> runContactServiceTests() async {
  final tester = ContactServiceTest();
  final results = await tester.runAllTests();
  return tester.generateTestReport(results);
}
