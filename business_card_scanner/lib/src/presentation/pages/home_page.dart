import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/business_card.dart';
import '../../services/database_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bcs_container.dart';
import 'camera_page.dart';
import 'business_card_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BusinessCard> _businessCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessCards();
  }

  Future<void> _loadBusinessCards() async {
    try {
      final databaseService = GetIt.instance<DatabaseService>();
      final cards = await databaseService.getAllBusinessCards();
      setState(() {
        _businessCards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load business cards: $e');
    }
  }

  void _navigateToCamera() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CameraPage()));

    if (result == true) {
      _loadBusinessCards(); // Refresh the list
    }
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
        toolbarHeight: 64,
        leadingWidth: 88,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BcsContainer(
            height: 48,
            width: 48,
            borderRadius: BorderRadius.circular(50),
            child: const Icon(
              size: 48,
              Icons.account_circle_rounded,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: const Text('Business Card Scanner'),
      ),
      endDrawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with scan button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Scan Business Cards',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Capture and organize your business cards digitally',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _navigateToCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Scan New Card'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // Business cards list
                Expanded(
                  child: _businessCards.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No business cards yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap "Scan New Card" to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _businessCards.length,
                          itemBuilder: (context, index) {
                            final card = _businessCards[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
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
                                    if (card.company != null)
                                      Text(card.company!),
                                    if (card.jobTitle != null)
                                      Text(
                                        card.jobTitle!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () => _navigateToDetail(card),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCamera,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
