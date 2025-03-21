import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  List<dynamic> favoriteMedicines = [];
  int? userId; // Để null trước, sau đó lấy từ SharedPreferences

  FavoriteProvider() {
    _loadUserId(); // ✅ Khi khởi tạo, lấy user_id ngay
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id'); // ✅ Lấy user_id từ SharedPreferences
    print("🔹 FavoriteProvider - Lấy user ID: $userId");
    if (userId != null) {
      await loadFavorites(); // ✅ Khi có userId, tải danh sách yêu thích
    }
  }

  Future<void> loadFavorites() async {
    try {
      print("🔹 Gọi API lấy danh sách yêu thích của user ID: $userId");
      final result = await ApiService.getFavoriteMedicines(userId!);

      print("✅ Dữ liệu từ API: $result");

      favoriteMedicines = result;
      notifyListeners(); // 🚀 Đảm bảo notifyListeners() được gọi

      print("📢 Đã cập nhật favoriteMedicines và gọi notifyListeners()");
    } catch (e) {
      print("❌ Lỗi khi tải danh sách yêu thích: $e");
    }
  }

  Future<void> addFavorite(int medicineId, String note) async {
    if (userId == null) return;
    await ApiService.addFavoriteMedicine(
      userId: userId!,
      medicineId: medicineId,
      note: note,
    );
    await loadFavorites();
  }

  Future<void> removeFavorite(int medicineId) async {
    if (userId == null) return;
    await ApiService.removeFavoriteMedicine(
        userId: userId!, medicineId: medicineId);
    await loadFavorites();
  }

  Future<void> updateFavoriteNote(int medicineId, String newNote) async {
    if (userId == null) return;

    try {
      final response = await ApiService.updateFavoriteNote(
        userId: userId!,
        medicineId: medicineId,
        note: newNote,
      );

      if (response['success']) {
        await loadFavorites(); // Load lại danh sách để cập nhật ghi chú
      } else {
        print("❌ Lỗi cập nhật ghi chú: ${response['message']}");
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API cập nhật ghi chú: $e");
    }
  }

  bool isFavorite(int medicineId) {
    return favoriteMedicines
        .any((medicine) => medicine["Medicine"]["id"] == medicineId);
  }
}
