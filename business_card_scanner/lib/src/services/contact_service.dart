import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
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
        throw Exception('Contacts permission denied');
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
      if (businessCard.phone != null) {
        contact.phones = [Item(label: 'work', value: businessCard.phone!)];
      }

      // Add email if available
      if (businessCard.email != null) {
        contact.emails = [Item(label: 'work', value: businessCard.email!)];
      }

      // Add address if available
      if (businessCard.address != null) {
        contact.postalAddresses = [
          PostalAddress(
            label: 'work',
            street: businessCard.address!,
          )
        ];
      }

      // Save the contact
      await ContactsService.addContact(contact);
      return true;
    } catch (e) {
      throw Exception('Failed to add contact: $e');
    }
  }

  Future<bool> hasContactsPermission() async {
    try {
      final status = await Permission.contacts.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestContactsPermission() async {
    try {
      // Check current permission status
      final currentStatus = await Permission.contacts.status;

      if (currentStatus == PermissionStatus.granted) {
        return true;
      }

      if (currentStatus == PermissionStatus.denied) {
        // Request permission
        final status = await Permission.contacts.request();
        return status == PermissionStatus.granted;
      }

      if (currentStatus == PermissionStatus.permanentlyDenied) {
        // Open app settings for user to manually grant permission
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> canAddContacts() async {
    try {
      // Check if the device supports adding contacts
      return await hasContactsPermission() || await requestContactsPermission();
    } catch (e) {
      return false;
    }
  }
}
