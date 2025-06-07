import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/business_card.dart';
import '../../services/database_service.dart';
import '../../services/export_service.dart';
import 'business_card_detail_page.dart';

class BusinessCardListPage extends StatefulWidget {
  const BusinessCardListPage({super.key});

  @override
  State<BusinessCardListPage> createState() => _BusinessCardListPageState();
}

class _BusinessCardListPageState extends State<BusinessCardListPage> {
  List<BusinessCard> _businessCards = [];
  List<BusinessCard> _filteredCards = [];
  bool _isLoading = true;
  bool _isExporting = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBusinessCards();
    _searchController.addListener(_filterCards);
  }

  Future<void> _loadBusinessCards() async {
    try {
      final databaseService = GetIt.instance<DatabaseService>();
      final cards = await databaseService.getAllBusinessCards();
      setState(() {
        _businessCards = cards;
        _filteredCards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load business cards: $e');
    }
  }

  void _filterCards() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCards = _businessCards.where((card) {
        return (card.name?.toLowerCase().contains(query) ?? false) ||
            (card.company?.toLowerCase().contains(query) ?? false) ||
            (card.email?.toLowerCase().contains(query) ?? false) ||
            (card.phone?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _navigateToDetail(BusinessCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessCardDetailPage(
          imagePath: card.imagePath,
          existingCard: card,
        ),
      ),
    );
  }

  Future<void> _deleteCard(BusinessCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Business Card'),
        content: Text(
            'Are you sure you want to delete ${card.name ?? "this business card"}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final databaseService = GetIt.instance<DatabaseService>();
        await databaseService.deleteBusinessCard(card.id);
        _loadBusinessCards();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Business card deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        _showErrorDialog('Failed to delete business card: $e');
      }
    }
  }

  Future<void> _showExportOptions() async {
    if (_businessCards.isEmpty) {
      _showErrorDialog('No business cards to export');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Business Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              subtitle: const Text('Spreadsheet format'),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV();
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_page),
              title: const Text('Export as vCard'),
              subtitle: const Text('Contact format'),
              onTap: () {
                Navigator.pop(context);
                _exportAsVCard();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsCSV() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final exportService = GetIt.instance<ExportService>();
      final filePath = await exportService.exportToCSV(_businessCards);

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to export CSV: $e');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportAsVCard() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final exportService = GetIt.instance<ExportService>();
      final filePath = await exportService.exportToVCard(_businessCards);

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to export vCard: $e');
    } finally {
      setState(() {
        _isExporting = false;
      });
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Cards'),
        actions: [
          if (_businessCards.isNotEmpty)
            IconButton(
              onPressed: _isExporting ? null : _showExportOptions,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              tooltip: 'Export',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search business cards...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchController.text.isEmpty
                            ? Icons.credit_card
                            : Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'No business cards yet'
                            : 'No cards found',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = _filteredCards[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            (card.name?.isNotEmpty == true)
                                ? card.name![0].toUpperCase()
                                : 'BC',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          card.name ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (card.company != null) Text(card.company!),
                            if (card.jobTitle != null)
                              Text(
                                card.jobTitle!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _navigateToDetail(card);
                                break;
                              case 'delete':
                                _deleteCard(card);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _navigateToDetail(card),
                      ),
                    );
                  },
                ),
    );
  }
}
