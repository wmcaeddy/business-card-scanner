import 'package:flutter/material.dart';
import '../../models/business_card.dart';

class TextMappingPage extends StatefulWidget {
  final List<String> extractedTexts;
  final BusinessCard? initialCard;

  const TextMappingPage({
    super.key,
    required this.extractedTexts,
    this.initialCard,
  });

  @override
  State<TextMappingPage> createState() => _TextMappingPageState();
}

class _TextMappingPageState extends State<TextMappingPage> {
  late Map<String, String?> fieldValues;
  late List<String> availableTexts;
  
  final Map<String, String> fieldLabels = {
    'name': 'Name',
    'company': 'Company',
    'jobTitle': 'Job Title',
    'phone': 'Phone',
    'email': 'Email',
    'website': 'Website',
    'address': 'Address',
  };

  final Map<String, IconData> fieldIcons = {
    'name': Icons.person,
    'company': Icons.business,
    'jobTitle': Icons.work,
    'phone': Icons.phone,
    'email': Icons.email,
    'website': Icons.language,
    'address': Icons.location_on,
  };

  @override
  void initState() {
    super.initState();
    
    // Initialize field values from initial card or empty
    fieldValues = {
      'name': widget.initialCard?.name,
      'company': widget.initialCard?.company,
      'jobTitle': widget.initialCard?.jobTitle,
      'phone': widget.initialCard?.phone,
      'email': widget.initialCard?.email,
      'website': widget.initialCard?.website,
      'address': widget.initialCard?.address,
    };

    // Filter out texts that are already assigned
    availableTexts = widget.extractedTexts
        .where((text) => text.trim().isNotEmpty)
        .where((text) => !fieldValues.values.contains(text))
        .toList();
  }

  void _assignTextToField(String text, String field) {
    setState(() {
      // Remove text from previous field if it was assigned
      final previousField = fieldValues.entries
          .firstWhere((entry) => entry.value == text, orElse: () => const MapEntry('', null))
          .key;
      if (previousField.isNotEmpty) {
        fieldValues[previousField] = null;
      }

      // Assign text to new field
      fieldValues[field] = text;
      
      // Remove from available texts if not already removed
      availableTexts.remove(text);
    });
  }

  void _removeTextFromField(String field) {
    setState(() {
      final text = fieldValues[field];
      if (text != null) {
        fieldValues[field] = null;
        if (!availableTexts.contains(text)) {
          availableTexts.add(text);
        }
      }
    });
  }

  void _onTextDragCompleted(String text) {
    // Text was successfully dropped, remove from available texts
    setState(() {
      availableTexts.remove(text);
    });
  }

  BusinessCard _createBusinessCard() {
    final now = DateTime.now();
    return BusinessCard(
      id: widget.initialCard?.id ?? now.millisecondsSinceEpoch.toString(),
      name: fieldValues['name'],
      company: fieldValues['company'],
      jobTitle: fieldValues['jobTitle'],
      phone: fieldValues['phone'],
      email: fieldValues['email'],
      website: fieldValues['website'],
      address: fieldValues['address'],
      imagePath: widget.initialCard?.imagePath ?? '',
      createdAt: widget.initialCard?.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Text Fields'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_createBusinessCard());
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Text(
              'Drag and drop text snippets to the correct fields below. Tap on assigned text to remove it.',
              style: TextStyle(fontSize: 14, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Available texts section
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Text Snippets:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: availableTexts.isEmpty
                        ? const Center(
                            child: Text(
                              'All text snippets have been assigned',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableTexts.map((text) {
                              return Draggable<String>(
                                data: text,
                                feedback: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue),
                                    ),
                                    child: Text(
                                      text,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Text(
                                    text,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(),
          
          // Field mapping section
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Card Fields:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: fieldLabels.length,
                      itemBuilder: (context, index) {
                        final field = fieldLabels.keys.elementAt(index);
                        final label = fieldLabels[field]!;
                        final icon = fieldIcons[field]!;
                        final value = fieldValues[field];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: DragTarget<String>(
                            onAccept: (text) {
                              _assignTextToField(text, field);
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isHovering = candidateData.isNotEmpty;
                              
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isHovering 
                                      ? Colors.green.shade50 
                                      : Colors.white,
                                  border: Border.all(
                                    color: isHovering 
                                        ? Colors.green 
                                        : Colors.grey.shade300,
                                    width: isHovering ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(icon, color: Colors.blue),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            label,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          value != null
                                              ? GestureDetector(
                                                  onTap: () => _removeTextFromField(field),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.shade100,
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(
                                                        color: Colors.green.shade300,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            value,
                                                            style: const TextStyle(fontSize: 12),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        const Icon(
                                                          Icons.close,
                                                          size: 14,
                                                          color: Colors.red,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  'Drop text here or tap to manually enter',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    if (value == null)
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _showManualEntryDialog(field, label),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog(String field, String label) {
    final controller = TextEditingController(text: fieldValues[field] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          maxLines: field == 'address' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  fieldValues[field] = text;
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 