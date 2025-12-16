class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final UserData? data;
  final int statusCode;
  final Map<String, dynamic>? errors;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
    this.errors,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      statusCode: json['status_code'] ?? 0,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}

class UserData {
  final User user;
  final String accessToken;
  final String tokenType;

  UserData({
    required this.user,
    required this.accessToken,
    required this.tokenType,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: User.fromJson(json['user']),
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'password': password};
  }
}

class RegisterResponse {
  final bool success;
  final String message;
  final RegisterUserData? data;
  final int statusCode;
  final Map<String, dynamic>? errors;

  RegisterResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
    this.errors,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? RegisterUserData.fromJson(json['data'])
          : null,
      statusCode: json['status_code'] ?? 0,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}

class RegisterUserData {
  final int id;
  final String name;
  final String email;

  RegisterUserData({required this.id, required this.name, required this.email});

  factory RegisterUserData.fromJson(Map<String, dynamic> json) {
    return RegisterUserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
