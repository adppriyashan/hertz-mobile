import 'package:flutter/material.dart';
import 'package:hertzmobile/models/auth_models.dart';
import 'package:hertzmobile/services/api_service.dart';
import 'package:hertzmobile/services/token_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  final TokenService tokenService;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  AuthProvider({required this.apiService, required this.tokenService}) {
    _checkLoggedInStatus();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  void _checkLoggedInStatus() {
    _isLoggedIn = tokenService.isLoggedIn();
    if (_isLoggedIn) {
      _user = User(
        id: tokenService.getUserId() ?? 0,
        name: tokenService.getUserName() ?? '',
        email: tokenService.getUserEmail() ?? '',
      );
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final request = LoginRequest(email: email, password: password);
    final response = await apiService.login(request);

    if (response.success && response.data != null) {
      await tokenService.saveToken(
        response.data!.accessToken,
        userId: response.data!.user.id,
        userName: response.data!.user.name,
        userEmail: response.data!.user.email,
      );
      apiService.setAuthToken(response.data!.accessToken);
      _isLoggedIn = true;
      _user = response.data!.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final request = RegisterRequest(
      name: name,
      email: email,
      password: password,
    );
    final response = await apiService.register(request);

    if (response.success) {
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await tokenService.clearAuth();
    apiService.clearAuthToken();
    _isLoggedIn = false;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
