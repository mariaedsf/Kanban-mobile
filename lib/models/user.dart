class User {
  final String id;
  final String email;
  final String name;
  final String password;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password,
    };
  }
}