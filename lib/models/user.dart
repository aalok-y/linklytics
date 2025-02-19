class User {
  final int userId;
  final String token;

  User({required this.userId, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(userId: json["userId"], token: json["token"]);
  }
}
