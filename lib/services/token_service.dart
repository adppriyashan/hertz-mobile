import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  final SharedPreferences _prefs;

  TokenService(this._prefs);

  /// Save token and user info
  Future<void> saveToken(
    String token, {
    required int userId,
    required String userName,
    required String userEmail,
  }) async {
    await Future.wait([
      _prefs.setString(_tokenKey, token),
      _prefs.setInt(_userIdKey, userId),
      _prefs.setString(_userNameKey, userName),
      _prefs.setString(_userEmailKey, userEmail),
    ]);
  }

  /// Get stored token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Get stored user id
  int? getUserId() {
    return _prefs.getInt(_userIdKey);
  }

  /// Get stored user name
  String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  /// Get stored user email
  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  /// Clear all auth data
  Future<void> clearAuth() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_userIdKey),
      _prefs.remove(_userNameKey),
      _prefs.remove(_userEmailKey),
    ]);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return getToken() != null;
  }
}
