import 'package:flutter/material.dart';
import '../providers/favoriteDisease_provider.dart';
import 'package:provider/provider.dart';

class DiseaseScreenDetail extends StatefulWidget {
  final Map diseaseData;  // Đổi tên biến để rõ ràng

  DiseaseScreenDetail({required this.diseaseData});

  @override
  _DiseaseScreenDetail createState() => _DiseaseScreenDetail();
}

class _DiseaseScreenDetail extends State<DiseaseScreenDetail> {
  TextEditingController noteController = TextEditingController();

  // Xử lý xuống dòng hợp lý
  String formatText(String text) {
    return text.replaceAll(RegExp(r'\s{2,}'), '\n\n');
  }

  // Xử lý danh sách thành bullet points
  Widget formatList(String text) {
    List<String> items = text.split(RegExp(r'\n|;|-'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        if (item.trim().isEmpty) return SizedBox(); 
        return Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(fontWeight: FontWeight.bold)), 
              Expanded(child: Text(item.trim())),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Hàm build nội dung text hoặc list
  Widget buildContent(BuildContext context, String label, String? content) {
    if (content == null || content.isEmpty) return SizedBox(); // Kiểm tra null
    bool isList = content.contains(";") || content.contains("\n") || content.contains("-");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
        ),
        SizedBox(height: 6),
        isList ? formatList(content) : Text(formatText(content), style: TextStyle(fontSize: 16)),
        SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var favoriteProvider = Provider.of<FavoriteDiseaseProvider>(context);

    // Lấy dữ liệu bệnh từ widget.diseaseData
    var disease = widget.diseaseData;
    bool isFavorite = favoriteProvider.isFavorite(disease["id"] ?? 0);  // Kiểm tra null

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          disease['ten_benh'] ?? "Không có tên",
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
              buildContent(context, 'Tên bệnh', disease['ten_benh']),
              buildContent(context, 'Định nghĩa', disease['dinh_nghia']),
              buildContent(context, 'Nguyên nhân', disease['nguyen_nhan']),
              buildContent(context, 'Triệu chứng', disease['trieu_chung']),
              buildContent(context, 'Chẩn đoán', disease['chan_doan']),
              buildContent(context, 'Điều trị', disease['dieu_tri']),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isFavorite) {
            favoriteProvider.removeFavorite(disease["id"]);
          } else {
            _showNoteDialog(context, favoriteProvider);
          }
        },
        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, FavoriteDiseaseProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Thêm vào yêu thích"),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(labelText: "Ghi chú (tuỳ chọn)"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                await provider.addFavorite(widget.diseaseData["id"], noteController.text);
                Navigator.pop(context);
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }
}
