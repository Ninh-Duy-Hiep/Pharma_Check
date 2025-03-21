import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:3000/api/favoritesMedicine';

  // Thêm thuốc vào danh sách yêu thích
  static Future<Map<String, dynamic>> addFavoriteMedicine({
    required int userId,
    required int medicineId,
    required String note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "medicine_id": medicineId,
        "note": note,
      }),
    );

    return jsonDecode(response.body);
  }

  // Lấy danh sách thuốc yêu thích
  static Future<List<dynamic>> getFavoriteMedicines(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl?user_id=$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"];
    } else {
      return [];
    }
  }

  // Xóa thuốc khỏi danh sách yêu thích
  static Future<Map<String, dynamic>> removeFavoriteMedicine({
    required int userId,
    required int medicineId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/remove'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "medicine_id": medicineId,
      }),
    );

    return jsonDecode(response.body);
  }

  // Cập nhật ghi chú cho thuốc yêu thích
  static Future<Map<String, dynamic>> updateFavoriteNote({
    required int userId,
    required int medicineId,
    required String note,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update_note'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "medicine_id": medicineId,
        "note": note,
      }),
    );

    return jsonDecode(response.body);
  }
}
