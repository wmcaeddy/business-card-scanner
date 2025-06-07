import 'package:flutter/material.dart';
import '../../models/business_card.dart';
import '../../services/database_service.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBusinessCards();
    _searchController.addListener(_filterCards);
  }

  Future<void> _loadBusinessCards() async {
    try {
      final databaseService = DatabaseService();
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
        final databaseService = DatabaseService();
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
                            if (card.email != null)
                              Text(
                                card.email!,
                                style: TextStyle(
                                  color: Colors.blue[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToDetail(card);
                            } else if (value == 'delete') {
                              _deleteCard(card);
                            }
                          },
                        ),
                        onTap: () => _navigateToDetail(card),
                      ),
                    );
                  },
                ),
    );
  }
}
