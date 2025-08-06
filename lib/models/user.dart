class User {
  final int id;
  final String name;
  final String email;
  final String type;
  final String? role;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.role,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      type: json['type'] ?? 'default',
      role: json['role'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type,
      'role': role,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isAdmin => type == 'admin';
  bool get isDb => type == 'db';
  bool get isEmployee => type == 'employee';
  bool get isDefault => type == 'default';
  bool get isEmailVerified => emailVerifiedAt != null;

  String get displayType {
    switch (type) {
      case 'admin':
        return 'Administrator';
      case 'db':
        return 'Database Manager';
      case 'employee':
        return 'Employee';
      case 'default':
        return 'Default User';
      default:
        return 'Unknown';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 