import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/business_card.dart';

class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  Future<bool> addToContacts(BusinessCard businessCard) async {
    try {
      // Check and request permission first
      final hasPermission = await requestContactsPermission();
      if (!hasPermission) {
        throw Exception('Contacts permission denied. Please grant permission in Settings.');
      }

      // Validate that we have at least some contact information
      if (businessCard.name == null && 
          businessCard.company == null && 
          businessCard.phone == null && 
          businessCard.email == null) {
        throw Exception('No contact information available to save.');
      }

      // Create a new contact
      final nameParts = businessCard.name?.split(' ') ?? [];
      final contact = Contact(
        givenName: nameParts.isNotEmpty ? nameParts.first : null,
        familyName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : null,
        company: businessCard.company,
        jobTitle: businessCard.jobTitle,
      );

      // Add phone number if available
      if (businessCard.phone != null && businessCard.phone!.isNotEmpty) {
        contact.phones = [Item(label: 'work', value: businessCard.phone!)];
      }

      // Add email if available
      if (businessCard.email != null && businessCard.email!.isNotEmpty) {
        contact.emails = [Item(label: 'work', value: businessCard.email!)];
      }

      // Add address if available
      if (businessCard.address != null && businessCard.address!.isNotEmpty) {
        contact.postalAddresses = [
          PostalAddress(
            label: 'work',
            street: businessCard.address!,
          )
        ];
      }

      // Save the contact
      await ContactsService.addContact(contact);
      
      if (kDebugMode) {
        print('Contact added successfully: ${contact.givenName} ${contact.familyName}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add contact: $e');
      }
      throw Exception('Failed to add contact: $e');
    }
  }

  Future<bool> hasContactsPermission() async {
    try {
      final status = await Permission.contacts.status;
      if (kDebugMode) {
        print('Contacts permission status: $status');
      }
      return status == PermissionStatus.granted;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking contacts permission: $e');
      }
      return false;
    }
  }

  Future<bool> requestContactsPermission() async {
    try {
      // Check current permission status
      final currentStatus = await Permission.contacts.status;
      
      if (kDebugMode) {
        print('Current contacts permission status: $currentStatus');
      }

      if (currentStatus == PermissionStatus.granted) {
        return true;
      }

      if (currentStatus == PermissionStatus.denied || 
          currentStatus == PermissionStatus.restricted) {
        // Request permission
        final status = await Permission.contacts.request();
        if (kDebugMode) {
          print('Permission request result: $status');
        }
        return status == PermissionStatus.granted;
      }

      if (currentStatus == PermissionStatus.permanentlyDenied) {
        // Show dialog to user about opening settings
        if (kDebugMode) {
          print('Permission permanently denied, opening app settings');
        }
        await openAppSettings();
        return false;
      }

      // For limited status (iOS 14+)
      if (currentStatus == PermissionStatus.limited) {
        return true; // Limited access is still usable for adding contacts
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting contacts permission: $e');
      }
      return false;
    }
  }

  Future<bool> canAddContacts() async {
    try {
      // Check if the device supports adding contacts
      final hasPermission = await hasContactsPermission();
      if (hasPermission) return true;
      
      // Try to request permission
      return await requestContactsPermission();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if can add contacts: $e');
      }
      return false;
    }
  }

  /// Test method to verify contacts functionality
  Future<bool> testContactsAccess() async {
    try {
      final hasPermission = await requestContactsPermission();
      if (!hasPermission) {
        return false;
      }

      // Try to get contacts count (read access test)
      final contacts = await ContactsService.getContacts(withThumbnails: false);
      if (kDebugMode) {
        print('Contacts access test successful. Found ${contacts.length} contacts.');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Contacts access test failed: $e');
      }
      return false;
    }
  }
}
