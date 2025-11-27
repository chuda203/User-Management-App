class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? 'https://randomuser.me/api/portraits/lego/1.jpg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatar': avatar,
    };
  }
}