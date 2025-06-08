import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? selectedText;

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
          .firstWhere((entry) => entry.value == text,
              orElse: () => const MapEntry('', null))
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

  void _selectText(String text) {
    setState(() {
      selectedText = selectedText == text ? null : text;
    });
  }

  void _splitTextWithSpace() {
    if (selectedText == null) return;

    final parts = selectedText!
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.length > 1) {
      setState(() {
        availableTexts.remove(selectedText);
        availableTexts.addAll(parts);
        selectedText = null;
      });
    }
  }

  void _filterPhoneNumber() {
    if (selectedText == null) return;

    // Extract only numbers and plus sign
    final filtered = selectedText!.replaceAll(RegExp(r'[^\d+]'), '');
    if (filtered != selectedText) {
      setState(() {
        final index = availableTexts.indexOf(selectedText!);
        if (index != -1) {
          availableTexts[index] = filtered;
          selectedText = filtered;
        }
      });
    }
  }

  void _copyText() {
    if (selectedText != null) {
      Clipboard.setData(ClipboardData(text: selectedText!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
      );
    }
  }

  void _deleteText() {
    if (selectedText != null) {
      setState(() {
        availableTexts.remove(selectedText);
        selectedText = null;
      });
    }
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

  void _saveBusinessCard() {
    Navigator.of(context).pop(_createBusinessCard());
  }

  void _saveToContact() {
    // TODO: Implement save to contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Save to Contact functionality will be implemented')),
    );
  }

  void _saveBothBusinessCardAndContact() {
    // TODO: Implement save both functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Save Both functionality will be implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Text Fields'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: const Text(
              'Select text to perform operations, then drag to fields below',
              style: TextStyle(fontSize: 14, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ),

          // Two halves layout
          Expanded(
            child: Row(
              children: [
                // Left half - Available texts with operations
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Column(
                      children: [
                        // Header with text operations
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.grey.shade50,
                          child: Column(
                            children: [
                              const Text(
                                'Captured Text',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (selectedText != null) ...[
                                Text(
                                  'Selected: ${selectedText!.length > 30 ? "${selectedText!.substring(0, 30)}..." : selectedText!}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  children: [
                                    _buildOperationButton(
                                      icon: Icons.space_bar,
                                      label: 'Split',
                                      onPressed: _splitTextWithSpace,
                                    ),
                                    _buildOperationButton(
                                      icon: Icons.phone,
                                      label: 'Phone',
                                      onPressed: _filterPhoneNumber,
                                    ),
                                    _buildOperationButton(
                                      icon: Icons.copy,
                                      label: 'Copy',
                                      onPressed: _copyText,
                                    ),
                                    _buildOperationButton(
                                      icon: Icons.delete,
                                      label: 'Delete',
                                      onPressed: _deleteText,
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ] else
                                const Text(
                                  'Tap text below to select and perform operations',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),

                        // Scrollable text list
                        Expanded(
                          child: availableTexts.isEmpty
                              ? const Center(
                                  child: Text(
                                    'All text snippets have been assigned',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: availableTexts.length,
                                  itemBuilder: (context, index) {
                                    final text = availableTexts[index];
                                    final isSelected = selectedText == text;

                                    return Draggable<String>(
                                      data: text,
                                      feedback: Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 200),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border:
                                                Border.all(color: Colors.blue),
                                          ),
                                          child: Text(
                                            text,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 4),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () => _selectText(text),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 4),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.blue.shade100
                                                : Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.blue.shade200,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            text,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right half - Form fields
                Expanded(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.grey.shade50,
                        child: const Text(
                          'Business Card Fields',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Scrollable form
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
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
                                builder:
                                    (context, candidateData, rejectedData) {
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
                                        Icon(icon,
                                            color: Colors.blue, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                label,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              value != null
                                                  ? GestureDetector(
                                                      onTap: () =>
                                                          _removeTextFromField(
                                                              field),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 6,
                                                          vertical: 3,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .green.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          border: Border.all(
                                                            color: Colors
                                                                .green.shade300,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                value,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            11),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            const Icon(
                                                              Icons.close,
                                                              size: 12,
                                                              color: Colors.red,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      'Drop text here',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        if (value == null)
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 16),
                                            onPressed: () =>
                                                _showManualEntryDialog(
                                                    field, label),
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
              ],
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveToContact,
                    icon: const Icon(Icons.contact_page),
                    label: const Text('Save to Contact'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveBothBusinessCardAndContact,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Both'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 10)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue.shade100,
          foregroundColor: color ?? Colors.blue.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
        ),
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
