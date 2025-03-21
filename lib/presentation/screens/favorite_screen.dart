import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import 'medicine_detail_screen.dart';
import '../providers/label_provider.dart';
class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Danh sách yêu thích")),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.favoriteMedicines.isEmpty) {
            return Center(child: Text("Chưa có thuốc yêu thích nào"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: favoriteProvider.favoriteMedicines.length,
            itemBuilder: (context, index) {
              var medicine =
                  favoriteProvider.favoriteMedicines[index]["Medicine"];
              var note = favoriteProvider.favoriteMedicines[index]["note"] ??
                  "Không có";

              String displayedNote =
                  note.length > 30 ? note.substring(0, 30) + "..." : note;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      medicine["hinh_anh"],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    medicine["ten_thuoc"],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Ghi chú: $displayedNote"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.note, color: Colors.blue),
                        onPressed: () =>
                            _showNoteDialog(context, note, medicine["id"]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            favoriteProvider.removeFavorite(medicine["id"]),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicineDetailScreen(medicine: medicine),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<LabelProvider>(
            builder: (context, labelProvider, child) {
              return labelProvider.labels.isNotEmpty
                  ? Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3)],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: null,
                    hint: Text("Chọn nhãn"),
                    items: labelProvider.labels.map((label) {
                      return DropdownMenuItem<String>(
                        value: label["id"].toString(),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: Color(int.parse(label["color"])),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(label["name"]),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  ),
                ),
              )
                  : SizedBox.shrink();
            },
          ),
          FloatingActionButton(
            onPressed: () => _showCreateLabelDialog(context),
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(BuildContext context, String currentNote, int medicineId) {
    TextEditingController noteController =
        TextEditingController(text: currentNote);
    bool isEditing = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? "Chỉnh sửa ghi chú" : "Ghi chú"),
              content: isEditing
                  ? TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration:
                          InputDecoration(hintText: "Nhập ghi chú mới..."),
                    )
                  : SingleChildScrollView(
                      child: Text(currentNote, style: TextStyle(fontSize: 16)),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Đóng"),
                ),
                if (!isEditing)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    child: Text("Chỉnh sửa"),
                  ),
                if (isEditing)
                  TextButton(
                    onPressed: () {
                      final newNote = noteController.text.trim();
                      if (newNote.isNotEmpty) {
                        Provider.of<FavoriteProvider>(context, listen: false)
                            .updateFavoriteNote(medicineId, newNote);
                      }
                      Navigator.pop(context);
                    },
                    child: Text("Lưu"),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateLabelDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    String selectedColor = "0xFF2196F3"; // Mặc định màu xanh

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Thêm nhãn mới"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ Giúp tránh lỗi tràn nội dung
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Tên nhãn"),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _colorPicker("0xFF2196F3", selectedColor, () {
                          setState(() {
                            selectedColor = "0xFF2196F3";
                          });
                        }),
                        _colorPicker("0xFFFFC107", selectedColor, () {
                          setState(() {
                            selectedColor = "0xFFFFC107";
                          });
                        }),
                        _colorPicker("0xFF4CAF50", selectedColor, () {
                          setState(() {
                            selectedColor = "0xFF4CAF50";
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Hủy"),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      Provider.of<LabelProvider>(context, listen: false)
                          .createLabel(nameController.text.trim(), selectedColor);
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Tạo"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _colorPicker(String color, String selectedColor, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Color(int.parse(color.substring(2), radix: 16)),  // ✅ Sửa lỗi
          shape: BoxShape.circle,
          border: selectedColor == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }



}
