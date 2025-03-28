import 'package:flutter/material.dart';
import '../services/label_service.dart';
import 'dart:convert';

class LabelProvider with ChangeNotifier {
  final LabelService _labelService = LabelService();
  List<dynamic> _labels = [];
  List<dynamic> _labelDetails = [];
  String? selectedLabel; // Nhãn đang được chọn
  List<dynamic> filteredItems = []; // Dữ liệu sau khi lọc
  bool _isLoading = false;

  List<dynamic> get labels => _labels;
  List<dynamic> get labelDetails => _labelDetails;
  bool get isLoading => _isLoading;
  // String? get selectedLabelId => _selectedLabelId;

  Future<void> fetchLabels() async {
    try {
      // print("🔄 Đang lấy danh sách nhãn...");
      _labels = await _labelService.getLabels(); // Gọi API lấy danh sách mới
      notifyListeners(); // Cập nhật UI
      // print("✅ Danh sách nhãn sau khi cập nhật: $_labels");
    } catch (e) {
      print("❌ Lỗi khi tải danh sách nhãn: $e");
    }
  }

  Future<void> addLabel(String name, String color) async {
    var response = await _labelService.createLabel(name, color);
    if (response['success']) {
      fetchLabels();
    }
  }

  Future<void> editLabel(int id, String? name, String? color) async {
    await _labelService.updateLabel(id, name, color);

    // Tạo danh sách mới để Flutter nhận diện thay đổi
    _labels = _labels.map((label) {
      if (label['id'] == id) {
        return {
          'id': id,
          'name': name ?? label['name'],
          'color': color ?? label['color'],
        };
      }
      return label;
    }).toList(); // Tạo danh sách mới hoàn toàn

    notifyListeners(); // Thông báo cập nhật UI
  }

  Future<void> removeLabel(int id) async {
    try {
      // Gọi API để xóa nhãn
      final response = await _labelService.deleteLabel(id);

      if (response['success']) {
        _labels.removeWhere((label) => label['id'] == id);
        notifyListeners();
        // print("✅ Xóa nhãn thành công");
      } else {
        print("❌ Lỗi xóa nhãn: ${response['message']}");
        await fetchLabels();
      }
    } catch (e) {
      print("❌ Lỗi khi xóa nhãn: $e");
      // Nếu có lỗi, load lại danh sách để đảm bảo UI chính xác
      await fetchLabels();
    }
  }

  Future<Map<String, dynamic>> assignLabel(int labelId,
      {int? favoriteDiseaseId, int? favoriteMedicineId}) async {
    final result = await _labelService.assignLabel(
      labelId,
      favoriteDiseaseId: favoriteDiseaseId,
      favoriteMedicineId: favoriteMedicineId,
    );

    if (result.containsKey('success') && result['success'] == true) {
      print("Gán thành công");
      await fetchLabels(); // 🔄 Cập nhật danh sách nhãn trước
      print("🔄 Danh sách nhãn sau fetchLabels: ${jsonEncode(_labelDetails)}");
      filterByLabel(selectedLabel); // 🆕 Lọc lại dữ liệu với danh sách mới nhất
      fetchLabelDetails();
      Future.delayed(Duration(milliseconds: 200), () {
        notifyListeners();
      }); // 🔄 Cập nhật UI

      // print("🔄 notifyListeners() đã được gọi!");
    }

    return result; // Trả về kết quả
  }

  Future<void> fetchLabelDetails() async {
    // print("📡 Gọi getLabelDetails() từ API...");
    _labelDetails = await LabelService().getLabelDetails();
    // print("📥 Dữ liệu lấy được từ API: ${jsonEncode(_labelDetails)}");
    notifyListeners();
  }

  void filterByLabel(String? labelName) {
    selectedLabel = labelName;
    print("🔍 Nhãn được chọn: $labelName");
    if (labelName == null || labelName == "Tất cả nhãn") {
      filteredItems = []; // Hiển thị lại danh sách thuốc yêu thích ban đầu
      // print("📌 Chế độ hiển thị tất cả dữ liệu.");
    } else {
      // print("📂 Dữ liệu từ getLabelDetails: ${jsonEncode(_labelDetails)}");
      filteredItems = _labelDetails
          .where((item) => item["labelName"] == labelName)
          .map((item) {
            if (item["favoriteMedicine"] != null) {
              print(
                  "✅ Tìm thấy thuốc: ${item["favoriteMedicine"]["medicineName"]}");
              return {
                "type": "medicine",
                "name": item["favoriteMedicine"]["medicineName"],
                "medicineData": item["favoriteMedicine"],
              };
            } else if (item["favoriteDisease"] != null) {
              // print(
              //     "✅ Tìm thấy bệnh: ${item["favoriteDisease"]["diseaseName"]}");
              return {
                "type": "disease",
                "name": item["favoriteDisease"]["diseaseName"],
              };
            }
            return null;
          })
          .where((item) => item != null)
          .toList();
      // print("📝 Danh sách sau khi lọc: ${jsonEncode(filteredItems)}");
    }
    notifyListeners();
  }
}
