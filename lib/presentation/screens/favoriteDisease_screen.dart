import 'package:flutter/material.dart';
import 'package:pharma_check/app.dart';
import 'package:pharma_check/presentation/screens/disease_screen_detail.dart';
import 'package:provider/provider.dart';
import '../providers/favoriteDisease_provider.dart';
import 'disease_screen_detail.dart';
import '../providers/label_provider.dart';
import '../widgets/color_picker_dialog.dart';

class FavoriteDiseaseScreen extends StatefulWidget {
  const FavoriteDiseaseScreen({super.key});

  @override
  _FavoriteDiseasesScreenState createState() => _FavoriteDiseasesScreenState();
}

class _FavoriteDiseasesScreenState extends State<FavoriteDiseaseScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<FavoriteDiseaseProvider>(context, listen: false)
        .loadFavorites();
  }

  bool _showButtons = false;

  @override
  Widget build(BuildContext context) {
    var favoriteProvider = Provider.of<FavoriteDiseaseProvider>(context);
    var favoriteDiseases =
        favoriteProvider.favoriteDiseases; // Lấy danh sách bệnh yêu thích

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), // Giữ nguyên chiều cao
          child: Consumer<LabelProvider>(
            builder: (context, provider, child) {
              print("🔄 Rebuilding UI do LabelProvider thay đổi!!!!!!!!!");
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.blueGrey.shade300, width: 1.5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text(
                      "Chọn nhãn",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    value: provider.selectedLabel, // Giá trị đã chọn
                    onChanged: (String? newValue) {
                      provider
                          .filterByLabel(newValue); // Gọi hàm lọc khi chọn nhãn
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    items: [
                      const DropdownMenuItem<String>(
                        value: "Tất cả nhãn",
                        child: Text("Tất cả nhãn"),
                      ),
                      ...provider.labels.map<DropdownMenuItem<String>>((label) {
                        return DropdownMenuItem<String>(
                          value: label["name"],
                          child: Text(label["name"] ?? "Không có tên"),
                        );
                      }).toList(),
                    ],
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.blueGrey, size: 28),
                  )),
                ),
              );
            },
          ),
        ),
      ),
      body: Consumer<LabelProvider>(
        builder: (context, labelProvider, child) {
          // Nếu chưa chọn nhãn, hiển thị danh sách thuốc yêu thích ban đầu
          if (labelProvider.selectedLabel == null ||
              labelProvider.selectedLabel == "Tất cả nhãn") {
            return Consumer<FavoriteDiseaseProvider>(
              builder: (context, provider, child) {
                if (provider.favoriteDiseases.isEmpty) {
                  return const Center(
                      child: Text("Không có thuốc yêu thích nào."));
                }
                return ListView.builder(
                  itemCount: favoriteDiseases.length,
                  itemBuilder: (context, index) {
                    var disease = favoriteDiseases[index];
                    // print("Dữ liệu bệnh nhận được: $disease"); // Debug

                    var diseaseData = disease['Disease']; // Lấy object Disease
                    // print("Dữ liệu Disease nhận được: $diseaseData"); // Debug

                    if (diseaseData == null) {
                      print("LỖI: diseaseData đang bị null!");
                    }
                    var note =
                        disease['note'] ?? 'Không có ghi chú'; // Lấy ghi chú

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(diseaseData?['ten_benh'] ?? 'Không có tên'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ghi chú: $note",
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.note, color: Colors.blue),
                              onPressed: () => _showNoteDialog(
                                  context,
                                  favoriteProvider,
                                  disease["Disease"]["id"],
                                  note),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmationDialog(
                                  context,
                                  favoriteProvider,
                                  disease["Disease"]["id"]),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.label, color: Colors.green),
                              onPressed: () {
                                final labelProvider =
                                    Provider.of<LabelProvider>(context,
                                        listen: false);
                                int diseaseId = disease["Disease"]
                                    ["id"]; // Lấy ID của thuốc
                                showLabelListBottomSheet(context, labelProvider,
                                    diseaseId: diseaseId);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          var diseaseData =
                              disease['Disease']; // Đúng cách lấy dữ liệu
                          print(
                              "Dữ liệu Disease trước khi chuyển trang: $diseaseData");

                          if (diseaseData == null || diseaseData.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Dữ liệu không hợp lệ!")),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DiseaseScreenDetail(diseaseData: diseaseData),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          } else {
            // Hiển thị danh sách đã lọc
            if (labelProvider.filteredItems.isEmpty) {
              return const Center(child: Text("Không có dữ liệu ."));
            }
            return ListView.builder(
              itemCount: labelProvider.filteredItems.length,
              itemBuilder: (context, index) {
                final item = labelProvider.filteredItems[index];
                return ListTile(
                  leading: Icon(
                    item["type"] == "medicine"
                        ? Icons.medical_services
                        : Icons.local_hospital,
                    color: Colors.blue,
                  ),
                  title: Text(
                    item["name"],
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: _showButtons ? 1.0 : 0.0,
            child: Visibility(
              visible: _showButtons,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "list_labels",
                    onPressed: () {
                      final labelProvider =
                          Provider.of<LabelProvider>(context, listen: false);
                      showLabelListBottomSheet(context, labelProvider);
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.list, size: 30, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "add_label",
                    onPressed: () => _showAddLabelDialog(context),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.add, size: 30, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          FloatingActionButton.small(
            heroTag: "toggle_buttons",
            onPressed: () {
              setState(() {
                _showButtons = !_showButtons;
              });
            },
            backgroundColor: Colors.blue,
            child: Icon(
              _showButtons ? Icons.close : Icons.more_vert,
              size: 15, // Kích thước icon nhỏ hơn
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Tạo nhãn dán mới
  void _showAddLabelDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    String? errorText; // Biến để hiển thị lỗi

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Thêm Nhãn"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Tên nhãn",
                      errorText: errorText, // Hiển thị lỗi nếu có
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Chọn màu:"),
                  GestureDetector(
                    onTap: () async {
                      Color? pickedColor = await showDialog<Color>(
                        context: context,
                        builder: (context) => ColorPickerDialog(selectedColor),
                      );
                      if (pickedColor != null) {
                        setState(() => selectedColor = pickedColor);
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      setState(() {
                        errorText = "Vui lòng nhập tên nhãn!";
                      });
                    } else {
                      Provider.of<LabelProvider>(context, listen: false)
                          .addLabel(
                        nameController.text.trim(),
                        "#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}",
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Lưu"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Hiển thị danh sách nhãn đã tạo
  void showLabelListBottomSheet(
      BuildContext context, LabelProvider labelProvider,
      {int? medicineId, int? diseaseId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép mở rộng toàn màn hình
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)), // Bo góc phía trên
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300, // Giới hạn chiều cao (tương đương 5 dòng)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Danh sách nhãn",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),

              // Danh sách nhãn
              Expanded(
                child: labelProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: labelProvider.labels.length,
                        itemBuilder: (context, index) {
                          final label = labelProvider.labels[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8), // Cách lề hai bên
                            leading: CircleAvatar(
                              backgroundColor: Color(int.parse(
                                  "0xFF${label['color'].substring(1)}")),
                            ),
                            title: Text(
                              label['name'],
                              overflow: TextOverflow
                                  .ellipsis, // Nếu dài quá thì hiện "..."
                              maxLines: 1,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue, size: 25),
                                  onPressed: () {
                                    showEditLabelDialog(
                                        context, labelProvider, label);
                                    // Navigator.pop(context);
                                  }, // TODO: Thêm chức năng chỉnh sửa
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () => _confirmDeleteLabel(
                                      context, labelProvider, label['id']),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.green, size: 25),
                                  onPressed: () async {
                                    if (medicineId == null &&
                                        diseaseId == null) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Vui lòng chọn thuốc hoặc bệnh để gán nhãn!'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    final result =
                                        await labelProvider.assignLabel(
                                      label['id'],
                                      favoriteMedicineId: medicineId,
                                      favoriteDiseaseId: diseaseId,
                                    );

                                    if (result['success']) {
                                      labelProvider.filterByLabel(labelProvider
                                          .selectedLabel); // 🔄 Cập nhật danh sách lọc
                                      labelProvider.notifyListeners();

                                      if (context.mounted) {
                                        // Đóng BottomSheet trước
                                        Navigator.pop(context);
                                        
                                        // Đợi một chút để BottomSheet đóng hoàn toàn
                                        await Future.delayed(const Duration(milliseconds: 100));
                                        
                                        if (context.mounted) {
                                          // Hiển thị thông báo sau khi BottomSheet đã đóng
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Gán nhãn '${label['name']}' thành công!",
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: const Duration(seconds: 2),
                                              behavior: SnackBarBehavior.floating,
                                              margin: const EdgeInsets.all(8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                        
                                        setState(() {}); // 🔄 Ép build lại UI
                                      }
                                    } else {
                                      // Đóng BottomSheet trước
                                      Navigator.pop(context);
                                      
                                      // Đợi một chút để BottomSheet đóng hoàn toàn
                                      await Future.delayed(const Duration(milliseconds: 100));
                                      
                                      if (context.mounted) {
                                        // Hiển thị thông báo lỗi sau khi BottomSheet đã đóng
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Bệnh đã được gán trong nhãn này !",
                                            ),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.all(8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hiển thị hộp thoại xác nhận xóa nhãn
  void _confirmDeleteLabel(
      BuildContext context, LabelProvider labelProvider, int labelId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc muốn xóa nhãn này không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                Navigator.of(context).pop();

                await labelProvider.removeLabel(labelId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Xóa nhãn thành công")),
                  );
                }
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Hiển thị hộp thoại xem và chỉnh sửa tên nhãn , màu nhãn
  void showEditLabelDialog(BuildContext context, LabelProvider labelProvider,
      Map<String, dynamic> label) {
    TextEditingController nameController =
        TextEditingController(text: label['name']);

    // Chuyển đổi từ mã hex sang Color
    Color selectedColor =
        Color(int.parse("0xFF${label['color'].substring(1)}"));

    bool isEditing = false; // Biến trạng thái để kiểm soát chế độ chỉnh sửa

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Thông tin nhãn"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isEditing
                      ? TextField(
                          controller: nameController,
                          decoration:
                              const InputDecoration(labelText: "Tên nhãn"),
                        )
                      : Text(nameController.text,
                          style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  const Text("Chọn màu:"),
                  GestureDetector(
                    onTap: () async {
                      Color? pickedColor = await showDialog<Color>(
                        context: context,
                        builder: (context) => ColorPickerDialog(selectedColor),
                      );
                      if (pickedColor != null) {
                        setState(() => selectedColor = pickedColor);
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Đóng"),
                ),
                if (isEditing)
                  TextButton(
                    onPressed: () async {
                      await labelProvider.editLabel(
                        label['id'],
                        nameController.text,
                        "#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}",
                      );

                      // Đóng hộp thoại chỉnh sửa trước
                      Navigator.of(context).pop();

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Cập nhật nhãn thành công")),
                      );

                    },
                    child: const Text("Lưu",
                        style: TextStyle(color: Colors.green)),
                  ),
                if (!isEditing)
                  TextButton(
                    onPressed: () {
                      setState(() =>
                          isEditing = true); // Chuyển sang chế độ chỉnh sửa
                    },
                    child: const Text("Chỉnh sửa",
                        style: TextStyle(color: Colors.blue)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // Hiển thị hộp thoại xác nhận xóa bệnh khỏi danh sách yêu thích
  void _showDeleteConfirmationDialog(
      BuildContext context, FavoriteDiseaseProvider provider, int diseaseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text(
              "Bạn có chắc chắn muốn xóa bệnh này khỏi danh sách yêu thích không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                provider.removeFavorite(diseaseId);
                Navigator.pop(context); // Đóng hộp thoại sau khi xóa
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  // Hiển thị hộp thoại xem & chỉnh sửa ghi chú
  void _showNoteDialog(BuildContext context, FavoriteDiseaseProvider provider,
      int diseaseId, String currentNote) {
    bool isEditing = false;
    TextEditingController noteController =
        TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Cho phép cập nhật UI trong dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Ghi chú"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isEditing
                      ? TextField(
                          controller: noteController,
                          decoration:
                              const InputDecoration(labelText: "Ghi chú mới"),
                        )
                      : Text(currentNote.isEmpty
                          ? "Không có ghi chú"
                          : currentNote),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Đóng"),
                ),
                if (isEditing)
                  ElevatedButton(
                    onPressed: () async {
                      await provider.updateNote(diseaseId, noteController.text);
                      Navigator.pop(context); // Đóng hộp thoại sau khi lưu
                    },
                    child: const Text("Lưu"),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    child: const Text("Chỉnh sửa"),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
