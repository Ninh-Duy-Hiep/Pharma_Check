import 'package:flutter/material.dart';

class DiseaseScreenDetail extends StatefulWidget {
  final Map diseaseId;

  DiseaseScreenDetail({required this.diseaseId});

  @override
  _DiseaseScreenDetail createState() => _DiseaseScreenDetail();
}

class _DiseaseScreenDetail extends State<DiseaseScreenDetail> {
  bool isFavorite = false;

  // Hàm xử lý nội dung có xuống dòng hợp lý
  String formatText(String text) {
    return text.replaceAll(RegExp(r'\s{2,}'), '\n\n'); // Xuống dòng khi gặp khoảng trắng dài
  }

  // Hàm xử lý danh sách thành bullet points
  Widget formatList(String text) {
    List<String> items = text.split(RegExp(r'\n|;|-')); // Tách danh sách bằng xuống dòng hoặc dấu chấm phẩy
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        if (item.trim().isEmpty) return SizedBox(); // Bỏ qua dòng trống
        return Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(fontWeight: FontWeight.bold)), // Gạch đầu dòng
              Expanded(child: Text(item.trim())),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Hàm build nội dung text hoặc list
  Widget buildContent(BuildContext context, String label, String content) {
    bool isList = content.contains(";") || content.contains("\n") || content.contains("-"); // Kiểm tra nếu nội dung là danh sách
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
        ),
        SizedBox(height: 6),
        isList ? formatList(content) : Text(formatText(content), style: TextStyle(fontSize: 16)),
        SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark; // Kiểm tra Dark Mode

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Áp dụng nền theo theme
      appBar: AppBar(
        title: Text(
          widget.diseaseId['ten_benh'],
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildContent(context, 'Tên bệnh', widget.diseaseId['ten_benh']),
              buildContent(context, 'Định nghĩa', widget.diseaseId['dinh_nghia']),
              buildContent(context, 'Nguyên nhân', widget.diseaseId['nguyen_nhan']),
              buildContent(context, 'Triệu chứng', widget.diseaseId['trieu_chung']),
              buildContent(context, 'Chẩn đoán', widget.diseaseId['chan_doan']),
              buildContent(context, 'Điều trị', widget.diseaseId['dieu_tri']),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isFavorite = !isFavorite;
          });
        },
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : (isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
