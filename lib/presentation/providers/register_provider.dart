import 'package:flutter/material.dart';
import '../services/register_service.dart';

class RegisterProvider with ChangeNotifier {
  final RegisterService _registerService = RegisterService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<String?> register(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final response = await _registerService.register(username, password);
    _isLoading = false;
    notifyListeners();

    return response["message"]; // Trả về thông báo từ server
  }
}
