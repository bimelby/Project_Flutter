class User {
  final String id;
  final String name;
  final String email;
  final String token;
  final String? profileImageUrl; // Tambahkan field untuk foto profil

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      token: json['token'],
      profileImageUrl: json['profile_image_url'], // Ambil dari JSON jika ada
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'profile_image_url': profileImageUrl,
    };
  }
}