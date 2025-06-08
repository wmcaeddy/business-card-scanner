import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/business_card.dart';

class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  /// Get current permission status
  Future<PermissionStatus> getPermissionStatus() async {
    try {
      final status = await Permission.contacts.status;
      if (kDebugMode) {
        print('Current contacts permission status: $status');
      }
      return status;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting contacts permission status: $e');
      }
      return PermissionStatus.denied;
    }
  }

  /// Check if we have contacts permission
  Future<bool> hasContactsPermission() async {
    try {
      final status = await getPermissionStatus();
      return status == PermissionStatus.granted ||
          status == PermissionStatus.limited;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking contacts permission: $e');
      }
      return false;
    }
  }

  /// Request contacts permission with detailed handling
  Future<PermissionStatus> requestContactsPermission() async {
    try {
      // Check current permission status
      final currentStatus = await getPermissionStatus();

      if (kDebugMode) {
        print('Current contacts permission status: $currentStatus');
      }

      // If already granted or limited, return current status
      if (currentStatus == PermissionStatus.granted ||
          currentStatus == PermissionStatus.limited) {
        return currentStatus;
      }

      // If permanently denied, we can't request again
      if (currentStatus == PermissionStatus.permanentlyDenied) {
        if (kDebugMode) {
          print(
              'Permission permanently denied, user needs to enable in settings');
        }
        return currentStatus;
      }

      // Request permission for denied or restricted status
      if (currentStatus == PermissionStatus.denied ||
          currentStatus == PermissionStatus.restricted) {
        final status = await Permission.contacts.request();
        if (kDebugMode) {
          print('Permission request result: $status');
        }
        return status;
      }

      return currentStatus;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting contacts permission: $e');
      }
      return PermissionStatus.denied;
    }
  }

  /// Open app settings for permission management
  Future<bool> openAppSettings() async {
    try {
      return await Permission.contacts.request().then((status) async {
        if (status.isPermanentlyDenied) {
          return await openAppSettings();
        }
        return status.isGranted;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error opening app settings: $e');
      }
      return false;
    }
  }

  /// Test contacts access by trying to read contacts
  Future<bool> testContactsAccess() async {
    try {
      final status = await getPermissionStatus();

      if (!status.isGranted && status != PermissionStatus.limited) {
        if (kDebugMode) {
          print(
              'Contacts access test failed: Permission not granted ($status)');
        }
        return false;
      }

      // Try to get contacts count (read access test)
      final contacts = await ContactsService.getContacts(withThumbnails: false);
      if (kDebugMode) {
        print(
            'Contacts access test successful. Found ${contacts.length} contacts.');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Contacts access test failed: $e');
      }
      return false;
    }
  }

  /// Add business card to contacts with enhanced validation and error handling
  Future<bool> addToContacts(BusinessCard businessCard) async {
    try {
      // Check and request permission first
      final permissionStatus = await requestContactsPermission();

      if (!permissionStatus.isGranted &&
          permissionStatus != PermissionStatus.limited) {
        String errorMessage = 'Contacts permission denied.';

        switch (permissionStatus) {
          case PermissionStatus.permanentlyDenied:
            errorMessage =
                'Contacts permission is permanently denied. Please enable it in Settings to save contacts.';
            break;
          case PermissionStatus.restricted:
            errorMessage = 'Contacts access is restricted on this device.';
            break;
          case PermissionStatus.denied:
            errorMessage =
                'Contacts permission was denied. Please grant permission to save contacts.';
            break;
          default:
            errorMessage =
                'Unable to access contacts. Permission status: ${permissionStatus.name}';
        }

        throw Exception(errorMessage);
      }

      // Validate that we have at least some contact information
      if (_isBusinessCardEmpty(businessCard)) {
        throw Exception(
            'No contact information available to save. Please add at least a name, phone number, or email address.');
      }

      // Create a new contact with enhanced field mapping
      final contact = _createContactFromBusinessCard(businessCard);

      // Save the contact
      await ContactsService.addContact(contact);

      if (kDebugMode) {
        print(
            'Contact added successfully: ${contact.displayName ?? 'Unknown'}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add contact: $e');
      }
      rethrow; // Re-throw to let the UI handle the specific error message
    }
  }

  /// Check if business card has any meaningful contact information
  bool _isBusinessCardEmpty(BusinessCard businessCard) {
    return (businessCard.name?.trim().isEmpty ?? true) &&
        (businessCard.company?.trim().isEmpty ?? true) &&
        (businessCard.phone?.trim().isEmpty ?? true) &&
        (businessCard.email?.trim().isEmpty ?? true);
  }

  /// Create a Contact object from BusinessCard with enhanced field mapping
  Contact _createContactFromBusinessCard(BusinessCard businessCard) {
    // Parse name into given and family names
    final nameParts = businessCard.name?.trim().split(' ') ?? [];
    String? givenName;
    String? familyName;

    if (nameParts.isNotEmpty) {
      givenName = nameParts.first;
      if (nameParts.length > 1) {
        familyName = nameParts.skip(1).join(' ');
      }
    }

    // Create the contact
    final contact = Contact(
      givenName: givenName,
      familyName: familyName,
      company: businessCard.company?.trim().isEmpty == true
          ? null
          : businessCard.company?.trim(),
      jobTitle: businessCard.jobTitle?.trim().isEmpty == true
          ? null
          : businessCard.jobTitle?.trim(),
    );

    // Add phone number if available
    if (businessCard.phone?.trim().isNotEmpty == true) {
      contact.phones = [
        Item(
          label: 'work',
          value: businessCard.phone!.trim(),
        )
      ];
    }

    // Add email if available
    if (businessCard.email?.trim().isNotEmpty == true) {
      contact.emails = [
        Item(
          label: 'work',
          value: businessCard.email!.trim(),
        )
      ];
    }

    // Add address if available
    if (businessCard.address?.trim().isNotEmpty == true) {
      contact.postalAddresses = [
        PostalAddress(
          label: 'work',
          street: businessCard.address!.trim(),
        )
      ];
    }

    // Note: Website and notes are not supported in contacts_service 0.6.3
    // They would need to be added to the contact's company or other fields if needed

    return contact;
  }

  /// Get permission status description for UI display
  String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted - You can save contacts';
      case PermissionStatus.denied:
        return 'Permission denied - Tap to request permission';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied - Please enable in Settings';
      case PermissionStatus.restricted:
        return 'Permission restricted - Contact access is not available';
      case PermissionStatus.limited:
        return 'Limited permission granted - You can save contacts';
      case PermissionStatus.provisional:
        return 'Provisional permission - You can save contacts';
    }
  }

  /// Check if we can add contacts (permission granted or can be requested)
  Future<bool> canAddContacts() async {
    try {
      final status = await getPermissionStatus();

      // If already granted or limited, we can add contacts
      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited) {
        return true;
      }

      // If denied or restricted, we can try to request
      if (status == PermissionStatus.denied ||
          status == PermissionStatus.restricted) {
        return true; // We can at least try to request
      }

      // If permanently denied, we can't add contacts without user going to settings
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if can add contacts: $e');
      }
      return false;
    }
  }
}
