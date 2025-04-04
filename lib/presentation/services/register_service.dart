import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  final String baseUrl = "http://192.168.60.152:3000/api/auth";

  Future<Map<String, dynamic>> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    return jsonDecode(response.body);
  }
}
