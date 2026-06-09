class Profile {
  final String id;
  final String name;
  final String role; // 'admin','cashier','waiter','kitchen'
  final String? phone;
  final String? email;
  final String? shiftStart;
  final String? shiftEnd;
  final String? avatarUrl;
  final bool isActive;

  Profile({
    required this.id,
    required this.name,
    required this.role,
    this.phone,
    this.email,
    this.shiftStart,
    this.shiftEnd,
    this.avatarUrl,
    required this.isActive,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      shiftStart: json['shift_start'] as String?,
      shiftEnd: json['shift_end'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
      'shift_start': shiftStart,
      'shift_end': shiftEnd,
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }

  Profile copyWith({
    String? id,
    String? name,
    String? role,
    String? phone,
    String? email,
    String? shiftStart,
    String? shiftEnd,
    String? avatarUrl,
    bool? isActive,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      shiftStart: shiftStart ?? this.shiftStart,
      shiftEnd: shiftEnd ?? this.shiftEnd,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
