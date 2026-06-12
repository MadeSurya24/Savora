class UserModel {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
