import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  String? _username;
  int? _userId; // ✅ Thêm user_id

  bool get isLoggedIn => _token != null;
  String? get role => _role;
  String? get username => _username;
  int? get userId => _userId; // ✅ Getter user_id

  Future<void> setAuth(String? token, String? role, [String? username, int? userId]) async {
    _token = token;
    _role = role;
    _username = username;
    _userId = userId; // ✅ Lưu user_id
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token ?? "");
    await prefs.setString('role', role ?? "");
    if (username != null) await prefs.setString('username', username);
    if (userId != null) {
      await prefs.setInt('user_id', userId);
      print("🔹 AuthProvider - Đã lưu user_id: $userId");
      print("🔹 SharedPreferences - user_id sau khi lưu: ${prefs.getInt('user_id')}");
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _username = null;
    _userId = null; // ✅ Reset user_id
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("🔹 AuthProvider - user_id trước khi logout: ${prefs.getInt('user_id')}");
    await prefs.clear();
    print("🔹 AuthProvider - Đã xóa tất cả dữ liệu trong SharedPreferences");
    // Provider.of<FavoriteMedicineProvider>(navigatorKey.currentContext!, listen: false).clearFavorites();
  }
}
