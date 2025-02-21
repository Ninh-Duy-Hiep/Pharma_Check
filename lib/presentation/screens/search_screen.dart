import 'package:flutter/material.dart';
import 'medicines_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedOption = "Tra cứu thuốc"; // Mặc định chọn tra cứu thuốc
  TextEditingController _searchController = TextEditingController();
  String currentSearchTerm = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text("Tra cứu", style: TextStyle(color: Colors.black)),
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
                    title: Text("Tra cứu thuốc"),
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
                    title: Text("Tra cứu bệnh"),
                    value: "Tra cứu bệnh",
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value!;
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
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Nhập tên ${_selectedOption.toLowerCase()}",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  // Nút tìm kiếm trong TextField
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.grey),
                    onPressed: () {
                      if (_selectedOption == "Tra cứu thuốc") {
                        setState(() {
                          currentSearchTerm = _searchController.text;
                        });
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (_selectedOption == "Tra cứu thuốc") {
                    setState(() {
                      currentSearchTerm = value;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 16),
            // Hiển thị kết quả tra cứu
            Expanded(
              child: _selectedOption == "Tra cứu thuốc"
                  ? _buildMedicineSearchScreen()
                  : _buildDiseaseSearchScreen(),
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
    return Center(
      child: Text(
        'Chưa có dữ liệu về bệnh',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}
