class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final double? farmSize;
  final String? location;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.farmSize,
    this.location,
    required this.preferredLanguage,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'farm_size': farmSize,
      'location': location,
      'preferred_language': preferredLanguage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      farmSize: json['farm_size']?.toDouble(),
      location: json['location'],
      preferredLanguage: json['preferred_language'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  User copyWith({
    String? name,
    String? phone,
    String? email,
    double? farmSize,
    String? location,
    String? preferredLanguage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      farmSize: farmSize ?? this.farmSize,
      location: location ?? this.location,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
