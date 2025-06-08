import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/foundation.dart';
import '../models/business_card.dart';

class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  /// Check if we have contacts permission
  Future<bool> hasContactsPermission() async {
    try {
      return await FlutterContacts.requestPermission(readonly: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking contacts permission: $e');
      }
      return false;
    }
  }

  /// Request contacts permission with detailed handling
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestContactsPermission() async {
    try {
      if (kDebugMode) {
        print('Requesting contacts permission...');
      }

      final hasPermission =
          await FlutterContacts.requestPermission(readonly: false);

      if (kDebugMode) {
        print('Contacts permission result: $hasPermission');
      }

      return hasPermission;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting contacts permission: $e');
      }
      return false;
    }
  }

  /// Test contacts access by trying to read contacts
  Future<bool> testContactsAccess() async {
    try {
      if (kDebugMode) {
        print('Testing contacts access...');
      }

      // First check if we have permission
      final hasPermission =
          await FlutterContacts.requestPermission(readonly: true);
      if (!hasPermission) {
        if (kDebugMode) {
          print('Contacts access test failed: Permission not granted');
        }
        return false;
      }

      // Try to get contacts count (read access test)
      final contacts = await FlutterContacts.getContacts();
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
      final hasPermission = await requestContactsPermission();

      if (!hasPermission) {
        throw Exception(
            'Contacts permission denied. Please grant permission to save contacts.');
      }

      // Validate that we have at least some contact information
      if (_isBusinessCardEmpty(businessCard)) {
        throw Exception(
            'No contact information available to save. Please add at least a name, phone number, or email address.');
      }

      // Create contact from business card
      final contact = _createContactFromBusinessCard(businessCard);

      // Insert the contact
      await FlutterContacts.insertContact(contact);

      if (kDebugMode) {
        print('Successfully added contact: ${contact.displayName}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding contact: $e');
      }
      rethrow;
    }
  }

  /// Check if business card has any meaningful contact information
  bool _isBusinessCardEmpty(BusinessCard businessCard) {
    final hasName = businessCard.name?.trim().isNotEmpty == true;
    final hasPhone = businessCard.phone?.trim().isNotEmpty == true;
    final hasEmail = businessCard.email?.trim().isNotEmpty == true;
    final hasCompany = businessCard.company?.trim().isNotEmpty == true;

    return !hasName && !hasPhone && !hasEmail && !hasCompany;
  }

  /// Create a flutter_contacts Contact from BusinessCard
  Contact _createContactFromBusinessCard(BusinessCard businessCard) {
    final contact = Contact();

    // Set name
    if (businessCard.name?.trim().isNotEmpty == true) {
      final nameParts = businessCard.name!.trim().split(' ');
      if (nameParts.isNotEmpty) {
        contact.name.first = nameParts.first;
        if (nameParts.length > 1) {
          contact.name.last = nameParts.skip(1).join(' ');
        }
      }
    }

    // Set company and job title
    if (businessCard.company?.trim().isNotEmpty == true) {
      final jobTitle = businessCard.jobTitle?.trim();
      contact.organizations = [
        Organization(
          company: businessCard.company!.trim(),
          title: (jobTitle != null && jobTitle.isNotEmpty) ? jobTitle : '',
        )
      ];
    }

    // Add phone number if available
    if (businessCard.phone?.trim().isNotEmpty == true) {
      contact.phones = [
        Phone(
          businessCard.phone!.trim(),
          label: PhoneLabel.work,
        )
      ];
    }

    // Add email if available
    if (businessCard.email?.trim().isNotEmpty == true) {
      contact.emails = [
        Email(
          businessCard.email!.trim(),
          label: EmailLabel.work,
        )
      ];
    }

    // Add address if available
    if (businessCard.address?.trim().isNotEmpty == true) {
      contact.addresses = [
        Address(
          businessCard.address!.trim(),
          label: AddressLabel.work,
        )
      ];
    }

    // Add website if available
    final website = businessCard.website?.trim();
    if (website != null && website.isNotEmpty) {
      contact.websites = [
        Website(
          website,
          label: WebsiteLabel.work,
        )
      ];
    }

    // Add notes if available
    if (businessCard.notes?.trim().isNotEmpty == true) {
      contact.notes = [Note(businessCard.notes!.trim())];
    }

    return contact;
  }

  /// Get all contacts for testing purposes
  Future<List<Contact>> getAllContacts() async {
    try {
      final hasPermission =
          await FlutterContacts.requestPermission(readonly: true);
      if (!hasPermission) {
        throw Exception('Permission denied to read contacts');
      }

      return await FlutterContacts.getContacts(withProperties: true);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all contacts: $e');
      }
      rethrow;
    }
  }

  /// Check if we can add contacts (permission available)
  Future<bool> canAddContacts() async {
    try {
      return await FlutterContacts.requestPermission(readonly: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if can add contacts: $e');
      }
      return false;
    }
  }

  /// Get permission status description for UI display
  String getPermissionStatusDescription(bool hasPermission) {
    return hasPermission
        ? 'Permission granted - You can save contacts'
        : 'Permission denied - Tap to request permission';
  }
}
