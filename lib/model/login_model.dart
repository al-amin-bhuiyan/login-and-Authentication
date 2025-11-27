class LoginModel {
  final String accessToken;
  final String? refreshToken;
  final String? username;
  final String? email;

  LoginModel({
    required this.accessToken,
    this.refreshToken,
    this.username,
    this.email,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      username: json['username'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'username': username,
    'email': email,
  };
}
