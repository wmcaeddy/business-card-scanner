class BusinessCard {
  final String id;
  final String? name;
  final String? company;
  final String? jobTitle;
  final String? phone;
  final String? email;
  final String? website;
  final String? address;
  final String? notes;
  final String imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessCard({
    required this.id,
    this.name,
    this.company,
    this.jobTitle,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.notes,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  BusinessCard copyWith({
    String? id,
    String? name,
    String? company,
    String? jobTitle,
    String? phone,
    String? email,
    String? website,
    String? address,
    String? notes,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessCard(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'jobTitle': jobTitle,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
      'notes': notes,
      'imagePath': imagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory BusinessCard.fromMap(Map<String, dynamic> map) {
    return BusinessCard(
      id: map['id'] ?? '',
      name: map['name'],
      company: map['company'],
      jobTitle: map['jobTitle'],
      phone: map['phone'],
      email: map['email'],
      website: map['website'],
      address: map['address'],
      notes: map['notes'],
      imagePath: map['imagePath'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BusinessCard(id: $id, name: $name, company: $company, phone: $phone, email: $email)';
  }
}
