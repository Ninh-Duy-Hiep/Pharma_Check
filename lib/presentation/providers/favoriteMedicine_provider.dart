import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/favoriteMedicine_service.dart';
import './label_provider.dart';
import 'package:provider/provider.dart';

class FavoriteMedicineProvider extends ChangeNotifier {
  List<dynamic> favoriteMedicines = [];
  List<dynamic> _favoriteMedicines = [];
  List<dynamic> get favoriteMedicinesList => _favoriteMedicines;
  int? userId; // Để null trước, sau đó lấy từ SharedPreferences

  FavoriteMedicineProvider() {
    _loadUserId(); // ✅ Khi khởi tạo, lấy user_id ngay
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    print("🔹 FavoriteMedicineProvider - Lấy user ID: $userId");
    print("🔹 SharedPreferences - user_id: ${prefs.getInt('user_id')}");
    if (userId != null) {
      await loadFavorites();
    }
  }

  Future<void> loadFavorites() async {
    try {
      // Lấy lại userId từ SharedPreferences trước khi gọi API
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');
      print("🔹 FavoriteMedicineProvider - loadFavorites - userId: $userId");

      if (userId == null) {
        print("❌ FavoriteMedicineProvider - userId là null, không thể load favorites");
        return;
      }

      print("🔹 Gọi API lấy danh sách yêu thích của user ID: $userId");
      final result = await ApiService.getFavoriteMedicines(userId!);

      print("✅ Dữ liệu từ API: $result");

      favoriteMedicines = result;
      _favoriteMedicines = result; // Cập nhật _favoriteMedicines
      await fetchFavoriteLabels();
      notifyListeners(); // 🚀 Đảm bảo notifyListeners() được gọi

      print("📢 Đã cập nhật favoriteMedicines và gọi notifyListeners()");
    } catch (e) {
      print("❌ Lỗi khi tải danh sách yêu thích: $e");
    }
  }

  Future<void> fetchFavoriteLabels() async {
    try {
      print("🔹 Gọi API lấy danh sách nhãn của thuốc yêu thích");
      final result = await ApiService.getFavoriteLabels(userId!);

      print("✅ Dữ liệu nhãn từ API: $result");

      // Cập nhật danh sách nhãn
      favoriteMedicines = favoriteMedicines.map((medicine) {
        final medicineId = medicine["Medicine"]["id"];
        final medicineLabels = result
            .where((label) => label["medicine_id"] == medicineId)
            .toList();

        return {
          ...medicine,
          "labels": medicineLabels,
        };
      }).toList();

      _favoriteMedicines = favoriteMedicines; // Cập nhật _favoriteMedicines
      notifyListeners();
    } catch (e) {
      print("❌ Lỗi khi tải danh sách nhãn: $e");
    }
  }

  Future<void> addFavorite(int medicineId, String note) async {
    if (userId == null) {
      print("❌ userId là null, không thể thêm vào favorites");
      return;
    }
    print("🔹 Thêm thuốc vào yêu thích với userId: $userId, medicineId: $medicineId, note: $note");
    print("🔹 SharedPreferences - user_id trước khi thêm: ${(await SharedPreferences.getInstance()).getInt('user_id')}");
    await ApiService.addFavoriteMedicine(
      userId: userId!,
      medicineId: medicineId,
      note: note,
    );
    print("🔹 SharedPreferences - user_id sau khi thêm: ${(await SharedPreferences.getInstance()).getInt('user_id')}");
    await loadFavorites();
  }

  Future<void> removeFavorite(BuildContext context, int medicineId) async {
    if (userId == null) return;
    await ApiService.removeFavoriteMedicine(
        userId: userId!, medicineId: medicineId);
    await loadFavorites();

    // Cập nhật danh sách lọc bằng cách lọc lại với nhãn hiện tại
    final labelProvider = Provider.of<LabelProvider>(context, listen: false);
    labelProvider.filterByLabel(labelProvider.selectedLabel);

    notifyListeners();
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

  List<dynamic> getFilteredMedicines(String? selectedLabel) {
    if (selectedLabel == null || selectedLabel == "Tất cả nhãn") {
      return favoriteMedicines; // Sử dụng favoriteMedicines thay vì _favoriteMedicines
    }
    return favoriteMedicines.where((medicine) {
      final labels = medicine["Medicine"]["labels"] as List<dynamic>;
      return labels.any((label) => label["labelName"] == selectedLabel);
    }).toList();
  }

  void clearFavorites() {
  favoriteMedicines = []; // Xóa danh sách cũ
  notifyListeners();
  }

}
