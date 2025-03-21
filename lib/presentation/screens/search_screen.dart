import 'package:flutter/material.dart';
import 'medicines_screen.dart';
import 'disease_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedOption = "Tra cứu thuốc";
  TextEditingController _searchController = TextEditingController();
  String currentSearchTerm = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Lấy theme hiện tại

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ Áp dụng nền Dark Mode
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor, // ✅ Áp dụng AppBar Dark Mode
        elevation: 1,
        title: Text(
          "Tra cứu",
          style: TextStyle(color: theme.textTheme.bodyLarge?.color), // ✅ Màu chữ theo theme
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      "Tra cứu thuốc",
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color), // ✅ Áp dụng màu chữ theo theme
                    ),
                    value: "Tra cứu thuốc",
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      "Tra cứu bệnh",
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color), // ✅ Áp dụng màu chữ theo theme
                    ),
                    value: "Tra cứu bệnh",
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value!;
                        currentSearchTerm = ""; // Xóa kết quả cũ khi đổi loại tra cứu
                        _searchController.clear(); // Xóa text trong ô tìm kiếm
                      });

                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Ô tìm kiếm
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant, // 🔹 Đổi màu nền theo theme
                borderRadius: BorderRadius.circular(8),
              ),

              child: TextField(
                controller: _searchController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                textInputAction: TextInputAction.done, // 🔹 Hỗ trợ nhập tiếng Việt đầy đủ
                keyboardType: TextInputType.text, // 🔹 Cho phép nhập text chuẩn
                decoration: InputDecoration(
                  hintText: "Nhập tên ${_selectedOption.toLowerCase()}",
                  hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: theme.iconTheme.color),
                    onPressed: () {
                      setState(() {
                        currentSearchTerm = _searchController.text;
                      });
                    },
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    currentSearchTerm = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            // Hiển thị kết quả tra cứu
            Expanded(
              child: _selectedOption == "Tra cứu thuốc"
                  ? MedicineListScreen(
                key: ValueKey("$_selectedOption-$currentSearchTerm"),
                searchTerm: currentSearchTerm,
              )
                  : DiseaseListScreen(
                key: ValueKey("$_selectedOption-$currentSearchTerm"),
                searchTerm: currentSearchTerm,
              ),

            ),
          ],
        ),
      ),
    );
  }

  // Trả về giao diện tra cứu thuốc, truyền từ khóa tìm kiếm và dùng ValueKey để khi từ khóa thay đổi, widget tái tạo
  Widget _buildMedicineSearchScreen() {
    return MedicineListScreen(
      key: ValueKey(currentSearchTerm),
      searchTerm: currentSearchTerm,
    );
  }

  // Giao diện tra cứu bệnh
  Widget _buildDiseaseSearchScreen() {
    return DiseaseListScreen(
      key: ValueKey(currentSearchTerm),
      searchTerm: currentSearchTerm,
    );
  }

}
