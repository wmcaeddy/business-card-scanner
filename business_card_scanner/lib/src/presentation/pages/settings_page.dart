import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../services/database_service.dart';
import '../../services/export_service.dart';
import 'contact_permission_test_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _totalCards = 0;
  String _exportDirectory = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final databaseService = GetIt.instance<DatabaseService>();
      final exportService = GetIt.instance<ExportService>();

      final cardCount = await databaseService.getBusinessCardCount();
      final exportDir = await exportService.getExportDirectory();

      setState(() {
        _totalCards = cardCount;
        _exportDirectory = exportDir;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all business cards? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final databaseService = GetIt.instance<DatabaseService>();
        await databaseService.deleteAllBusinessCards();

        setState(() {
          _totalCards = 0;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All business cards deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        _showErrorDialog('Failed to clear data: $e');
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.credit_card,
              size: 32,
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            const Text('About'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'BizScan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Version 1.0.0'),
              const SizedBox(height: 16),
              const Text(
                'A Flutter app for scanning and managing business cards using OCR technology.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• OCR text recognition'),
              const Text('• Contact integration'),
              const Text('• Export to CSV/vCard'),
              const Text('• Image cropping'),
              const Text('• Search functionality'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Statistics Section
                const ListTile(
                  title: Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('Total Business Cards'),
                  trailing: Text(
                    '$_totalCards',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(),

                // Export Section
                // const ListTile(
                //   title: Text(
                //     'Export',
                //     style: TextStyle(
                //       fontSize: 18,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.blue,
                //     ),
                //   ),
                // ),
                // ListTile(
                //   leading: const Icon(Icons.folder),
                //   title: const Text('Export Directory'),
                //   subtitle: Text(
                //     _exportDirectory,
                //     style: const TextStyle(fontSize: 12),
                //   ),
                // ),

                // const Divider(),

                // Permissions Section
                const ListTile(
                  title: Text(
                    'Permissions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.contact_phone),
                  title: const Text('Contact Permission Test'),
                  subtitle: const Text('Test and manage contacts permission'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ContactPermissionTestPage(),
                      ),
                    );
                  },
                ),

                const Divider(),

                // Data Management Section
                const ListTile(
                  title: Text(
                    'Data Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Delete all business cards'),
                  onTap: _clearAllData,
                ),

                const Divider(),

                // App Information Section
                const ListTile(
                  title: Text(
                    'App Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  subtitle: const Text('App version and information'),
                  onTap: _showAboutDialog,
                ),

                const SizedBox(height: 32),

                // Footer
                const Center(
                  child: Text(
                    'BizScan v1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
