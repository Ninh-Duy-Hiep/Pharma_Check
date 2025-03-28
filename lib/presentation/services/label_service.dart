import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LabelService {
  static const String baseUrl = "http://192.168.10.152:3000/api/labels";

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<Map<String, dynamic>> createLabel(String name, String color) async {
    int? userId = await _getUserId();
    if (userId == null)
      return {'success': false, 'message': 'User ID not found'};

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'name': name, 'color': color}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi tạo nhãn'};
    }
  }

  Future<List<dynamic>> getLabels() async {
    int? userId = await _getUserId();
    if (userId == null) return [];

    try {
      final response = await http.get(Uri.parse('$baseUrl?user_id=$userId'));
      return jsonDecode(response.body)['data'];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateLabel(
      int id, String? name, String? color) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'name': name, 'color': color}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật nhãn'};
    }
  }

  Future<Map<String, dynamic>> deleteLabel(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xóa nhãn'};
    }
  }

  Future<Map<String, dynamic>> assignLabel(int labelId,
      {int? favoriteDiseaseId, int? favoriteMedicineId}) async {
    int? userId = await _getUserId();
    if (userId == null) {
      return {'success': false, 'message': 'User ID not found'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assign'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'label_id': labelId,
          'favorite_disease_id': favoriteDiseaseId,
          'favorite_medicine_id': favoriteMedicineId
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Lỗi khi gán nhãn: ${response.statusCode}',
          'error': response.body
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi khi gán nhãn',
        'error': e.toString()
      };
    }
  }

  Future<List<dynamic>> getLabelDetails() async {
    int? userId = await _getUserId();
    if (userId == null) {
      print("❌ Không tìm thấy userId!");
      return [];
    }

    print("📡 Gọi API: $baseUrl/details?user_id=$userId");

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/details?user_id=$userId'));

      // print("📥 Phản hồi API (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          // print("✅ JSON Parse thành công: ${jsonEncode(responseData)}");

          return responseData['data'] ??
              []; // Tránh lỗi nếu 'data' không tồn tại
        } catch (e) {
          print("❌ Lỗi parse JSON: $e");
          return [];
        }
      } else {
        // print("❌ API lỗi ${response.statusCode}: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API: $e");
      return [];
    }
  }
}
