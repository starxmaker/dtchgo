class LoginResponse {
  final String message;
  final String csrfToken;
  LoginResponse({
    required this.message,
    required this.csrfToken
  });
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['mensaje'],
      csrfToken: json['csrfToken']
    );
  }
}

class AvailableResponse {
  final int quantity;
  AvailableResponse({
    required this.quantity
  });
  factory AvailableResponse.fromJson(Map<String, dynamic> json){
    return AvailableResponse(quantity: json['available']);
  }
}