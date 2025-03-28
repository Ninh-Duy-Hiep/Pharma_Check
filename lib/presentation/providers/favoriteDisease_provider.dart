// ignore: file_names
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/favoriteDisease_service.dart';

class FavoriteDiseaseProvider with ChangeNotifier {
  int? userId;
  List<Map<String, dynamic>> favoriteDiseases = [];

  FavoriteDiseaseProvider() {
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    if (userId != null) {
      await loadFavorites();
    }
  }

  // Tải danh sách bệnh yêu thích
  Future<void> loadFavorites() async {
    try {
      var diseases = await FavoriteDiseaseService.getFavoriteDiseases();

      // Kiểm tra null trước khi cập nhật danh sách
      favoriteDiseases = diseases ?? [];

      notifyListeners();
    } catch (e) {
      print("❌ Lỗi khi tải danh sách bệnh yêu thích: $e");
    }
  }

  // Thêm bệnh vào danh sách yêu thích
  Future<void> addFavorite(int diseaseId, String note) async {
    bool success =
        await FavoriteDiseaseService.addFavoriteDiseases(diseaseId, note);
    if (success) {
      await loadFavorites();
    }
  }

  // Xóa bệnh khỏi danh sách yêu thích
  Future<void> removeFavorite(int diseaseId) async {
    bool success =
        await FavoriteDiseaseService.removeFavoriteDiseases(diseaseId);
    if (success) {
      await loadFavorites();
    }
  }

  // Cập nhật ghi chú của bệnh yêu thích
  Future<void> updateNote(int diseaseId, String newNote) async {
    bool success =
        await FavoriteDiseaseService.updateNoteDiseases(diseaseId, newNote);
    if (success) {
      await loadFavorites();
    }
  }

  bool isFavorite(int diseaseId) {
    return favoriteDiseases
        .any((disease) => disease["Disease"]["id"] == diseaseId);
  }
}
