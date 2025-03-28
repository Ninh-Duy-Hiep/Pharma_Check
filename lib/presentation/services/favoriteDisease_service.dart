import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteDiseaseService {
  static const String baseUrl =
      "http://192.168.10.152:3000/api/favoritesDisease";

  // Lấy danh sách bệnh yêu thích theo user_id
  static Future<List<Map<String, dynamic>>> getFavoriteDiseases() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) return [];

    final response = await http.get(Uri.parse('$baseUrl?user_id=$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Dữ liệu API trả về: $data"); // Kiểm tra dữ liệu nhận được từ API

      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      throw Exception("Lỗi khi lấy danh sách bệnh yêu thích");
    }
  }

  // Thêm bệnh vào danh sách yêu thích
  static Future<bool> addFavoriteDiseases(int diseaseId, String note) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {"Content-Type": "application/json"},
      body: json
          .encode({"user_id": userId, "disease_id": diseaseId, "note": note}),
    );

    return response.statusCode == 201;
  }

  // Xóa bệnh khỏi danh sách yêu thích
  static Future<bool> removeFavoriteDiseases(int diseaseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/remove'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"user_id": userId, "disease_id": diseaseId}),
    );

    return response.statusCode == 200;
  }

  // Cập nhật ghi chú của bệnh yêu thích
  static Future<bool> updateNoteDiseases(int diseaseId, String newNote) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/update_note'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
          {"user_id": userId, "disease_id": diseaseId, "note": newNote}),
    );

    return response.statusCode == 200;
  }
}
