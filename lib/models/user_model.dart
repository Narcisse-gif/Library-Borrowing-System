class UserModel {
  final String id;
  late String name;
  final String email;
  final String role;
  final String? token; // add this

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token, // optional
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      token: json['token'], // get token if present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (token != null) 'token': token, // add token if present
    };
  }
}
