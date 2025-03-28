import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favoriteMedicine_provider.dart';
import 'package:url_launcher/url_launcher.dart';


class MedicineDetailScreen extends StatefulWidget {
  final Map medicine;

  MedicineDetailScreen({required this.medicine});

  @override
  _MedicineDetailScreenState createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  TextEditingController noteController = TextEditingController();

  void _showNoteDialog(
      BuildContext context, FavoriteMedicineProvider provider) {
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
                await provider.addFavorite(
                    widget.medicine["id"], noteController.text);
                Navigator.pop(context);
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("📌 Debug in MedicineDetailScreen: ${widget.medicine}");

    var favoriteProvider = Provider.of<FavoriteMedicineProvider>(context);
    bool isFavorite = favoriteProvider.isFavorite(widget.medicine["id"]);

    // Lấy thông tin từ Medicine object bên trong JSON
    final medicineData =
        widget.medicine["Medicine"] ?? {}; // Nếu null thì gán map rỗng

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.medicine['ten_thuoc'] ?? "Không có tên thuốc")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị hình ảnh thuốc
            Center(
              child: Image.network(
                widget.medicine['hinh_anh'] ?? "",
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image, size: 200, color: Colors.grey),
              ),
            ),
            SizedBox(height: 5),

            // Đường dẫn tìm kiếm trên Google
            InkWell(
              onTap: () {
                final searchQuery =
                    Uri.encodeComponent(widget.medicine['ten_thuoc'] ?? "");
                final url = "https://www.google.com/search?q=$searchQuery";
                launchUrl(Uri.parse(url));
              },
              child: Text(
                "🔍 Tìm kiếm trên Google",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  // decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Tên thuốc
            Text(widget.medicine['ten_thuoc'] ?? "Không có thông tin",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            Divider(),

            // Thành phần
            Text("Thành phần:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.medicine['thanh_phan'] ?? "Không có thông tin",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            // Công dụng
            Text("Công dụng:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.medicine['cong_dung'] ?? "Không có thông tin",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            // Tác dụng phụ
            Text("Tác dụng phụ:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.medicine['tac_dung_phu'] ?? "Không có thông tin",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            // Nhà sản xuất
            Text("Nhà sản xuất:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.medicine['nha_san_xuat'] ?? "Không có thông tin",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            Divider(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isFavorite) {
            favoriteProvider.removeFavorite(context, widget.medicine["id"]);
          } else {
            _showNoteDialog(context, favoriteProvider);
          }
        },
        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.red),
      ),
    );
  }
}
