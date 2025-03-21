import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Map medicine;

  MedicineDetailScreen({required this.medicine});

  @override
  _MedicineDetailScreenState createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  TextEditingController noteController = TextEditingController();

  void _showNoteDialog(BuildContext context, FavoriteProvider provider) {
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
                await provider.addFavorite(widget.medicine["id"], noteController.text);
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
    var favoriteProvider = Provider.of<FavoriteProvider>(context);
    bool isFavorite = favoriteProvider.isFavorite(widget.medicine["id"]);

    return Scaffold(
      appBar: AppBar(title: Text(widget.medicine['ten_thuoc'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị hình ảnh thuốc
            Center(
              child: Image.network(
                widget.medicine['hinh_anh'],
                height: 200,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 200, color: Colors.grey),
              ),
            ),
            SizedBox(height: 16),

            // Tên thuốc
            Text(widget.medicine['ten_thuoc'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            Divider(),

            // Thành phần
            Text("Thành phần:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.medicine['thanh_phan'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            // Công dụng
            Text("Công dụng:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.medicine['cong_dung'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            // Tác dụng phụ
            Text("Tác dụng phụ:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.medicine['tac_dung_phu'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            // Nhà sản xuất
            Text("Nhà sản xuất:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.medicine['nha_san_xuat'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            Divider(),

            // Đánh giá
            Text("Đánh giá:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Icon(Icons.sentiment_satisfied, color: Colors.green),
                SizedBox(width: 8),
                Text("Tốt: ${widget.medicine['danh_gia_tot']}"),
              ],
            ),
            Row(
              children: [
                Icon(Icons.sentiment_neutral, color: Colors.orange),
                SizedBox(width: 8),
                Text("Trung bình: ${widget.medicine['danh_gia_trung_binh']}"),
              ],
            ),
            Row(
              children: [
                Icon(Icons.sentiment_dissatisfied, color: Colors.red),
                SizedBox(width: 8),
                Text("Kém: ${widget.medicine['danh_gia_kem']}"),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isFavorite) {
            favoriteProvider.removeFavorite(widget.medicine["id"]);
          } else {
            _showNoteDialog(context, favoriteProvider);
          }
        },
        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
      ),
    );
  }
}
