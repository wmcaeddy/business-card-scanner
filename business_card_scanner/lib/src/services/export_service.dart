import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/business_card.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      if (status == PermissionStatus.granted) {
        return true;
      }

      if (status == PermissionStatus.denied) {
        final result = await Permission.storage.request();
        return result == PermissionStatus.granted;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> exportToCSV(List<BusinessCard> businessCards) async {
    try {
      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Create CSV content
      final csvContent = _generateCSVContent(businessCards);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'business_cards_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV content to file
      await file.writeAsString(csvContent);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  Future<String?> exportToVCard(List<BusinessCard> businessCards) async {
    try {
      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Create vCard content
      final vCardContent = _generateVCardContent(businessCards);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'business_cards_${DateTime.now().millisecondsSinceEpoch}.vcf';
      final file = File('${directory.path}/$fileName');

      // Write vCard content to file
      await file.writeAsString(vCardContent);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export vCard: $e');
    }
  }

  Future<String?> exportSingleVCard(BusinessCard businessCard) async {
    try {
      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Create vCard content for single card
      final vCardContent = _generateSingleVCard(businessCard);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${_sanitizeFileName(businessCard.name ?? 'business_card')}_${DateTime.now().millisecondsSinceEpoch}.vcf';
      final file = File('${directory.path}/$fileName');

      // Write vCard content to file
      await file.writeAsString(vCardContent);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export vCard: $e');
    }
  }

  String _generateCSVContent(List<BusinessCard> businessCards) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
        'Name,Company,Job Title,Phone,Email,Website,Address,Notes,Created At');

    // CSV Data
    for (final card in businessCards) {
      buffer.writeln([
        _escapeCsvField(card.name ?? ''),
        _escapeCsvField(card.company ?? ''),
        _escapeCsvField(card.jobTitle ?? ''),
        _escapeCsvField(card.phone ?? ''),
        _escapeCsvField(card.email ?? ''),
        _escapeCsvField(card.website ?? ''),
        _escapeCsvField(card.address ?? ''),
        _escapeCsvField(card.notes ?? ''),
        card.createdAt.toIso8601String(),
      ].join(','));
    }

    return buffer.toString();
  }

  String _generateVCardContent(List<BusinessCard> businessCards) {
    final buffer = StringBuffer();

    for (final card in businessCards) {
      buffer.write(_generateSingleVCard(card));
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _generateSingleVCard(BusinessCard businessCard) {
    final buffer = StringBuffer();

    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');

    // Name
    if (businessCard.name != null) {
      final nameParts = businessCard.name!.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
      buffer.writeln('FN:${businessCard.name}');
      buffer.writeln('N:$lastName;$firstName;;;');
    }

    // Organization
    if (businessCard.company != null) {
      buffer.writeln('ORG:${businessCard.company}');
    }

    // Title
    if (businessCard.jobTitle != null) {
      buffer.writeln('TITLE:${businessCard.jobTitle}');
    }

    // Phone
    if (businessCard.phone != null) {
      buffer.writeln('TEL;TYPE=WORK:${businessCard.phone}');
    }

    // Email
    if (businessCard.email != null) {
      buffer.writeln('EMAIL;TYPE=WORK:${businessCard.email}');
    }

    // Website
    if (businessCard.website != null) {
      buffer.writeln('URL:${businessCard.website}');
    }

    // Address
    if (businessCard.address != null) {
      buffer.writeln('ADR;TYPE=WORK:;;${businessCard.address};;;;');
    }

    // Notes
    if (businessCard.notes != null) {
      buffer.writeln('NOTE:${businessCard.notes}');
    }

    buffer.writeln('END:VCARD');

    return buffer.toString();
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
  }

  Future<String> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
