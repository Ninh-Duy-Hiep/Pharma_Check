import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LabelProvider extends ChangeNotifier {
  int? userId;
  List<Map<String, dynamic>> labels = [];

  LabelProvider() {
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id");
    if (userId != null) {
      fetchLabels();
    }
  }

  Future<void> fetchLabels() async {
    if (userId == null) return;
    final url = Uri.parse("http://10.0.2.2:3000/api/labels?user_id=$userId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        labels = List<Map<String, dynamic>>.from(data["data"]);
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách nhãn: $e");
    }
  }

  Future<void> createLabel(String name, String color) async {
    if (userId == null) return;

    final url = Uri.parse("http://10.0.2.2:3000/api/labels");
    final body = json.encode({"user_id": userId, "name": name, "color": color});

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        fetchLabels(); // Cập nhật danh sách sau khi tạo thành công
      }
    } catch (e) {
      print("Lỗi khi tạo nhãn: $e");
    }
  }
}
