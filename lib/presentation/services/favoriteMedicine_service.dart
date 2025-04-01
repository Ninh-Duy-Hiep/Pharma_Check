import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://192.168.60.152:3000/api/favoritesMedicine';

  // Thêm thuốc vào danh sách yêu thích
  static Future<Map<String, dynamic>> addFavoriteMedicine({
    required int userId,
    required int medicineId,
    required String note,
  }) async {
    final bodyData = jsonEncode({
      "user_id": userId,
      "medicine_id": medicineId,
      "note": note,
    });

    print("📤 Gửi request: $bodyData");
    print("🔹 ApiService - userId khi gọi API: $userId");

    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {"Content-Type": "application/json"},
      body: bodyData,
    );

    final responseData = jsonDecode(response.body);
    print("📥 API Response: $responseData");

    return responseData;
  }

  // Lấy danh sách thuốc yêu thích
  static Future<List<dynamic>> getFavoriteMedicines(int userId) async {
    print("🔍 Đang gọi API với userId: $userId");
    print("🔹 ApiService - userId khi lấy danh sách: $userId");
    final response = await http.get(Uri.parse('$baseUrl?user_id=$userId'));
    print("🔹 Response: ${response.body}");
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

  // 🆕 Hàm mới để lấy danh sách nhãn của thuốc yêu thích
  static Future<List<dynamic>> getFavoriteLabels(int userId) async {
    final url = Uri.parse("$baseUrl/favorite-labels?user_id=$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        print("❌ Lỗi khi lấy nhãn: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API: $e");
      return [];
    }
  }
}
