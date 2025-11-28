class LoginResponse {
  final String token;
  final bool success;
  final String message;

  LoginResponse({
    required this.token,
    required this.success,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}