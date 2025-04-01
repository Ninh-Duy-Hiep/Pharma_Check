import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class UpdateScreen extends StatefulWidget {
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  // Controllers cho thuốc
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _compositionController = TextEditingController();
  final TextEditingController _usesController = TextEditingController();
  final TextEditingController _sideEffectsController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _excellentReviewController = TextEditingController();
  final TextEditingController _averageReviewController = TextEditingController();
  final TextEditingController _poorReviewController = TextEditingController();

  // Controllers cho bệnh
  final TextEditingController _diseaseNameController = TextEditingController();
  final TextEditingController _defineController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _diagnoseController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();

  Future<void> _addMedicine() async {
    // Kiểm tra nếu các trường quan trọng trống
    if (_medicineNameController.text.isEmpty ||
        _compositionController.text.isEmpty ||
        _usesController.text.isEmpty ||
        _sideEffectsController.text.isEmpty ||
        _imageUrlController.text.isEmpty ||
        _manufacturerController.text.isEmpty ||
        _excellentReviewController.text.isEmpty ||
        _averageReviewController.text.isEmpty ||
        _poorReviewController.text.isEmpty) {
      // Thông báo nếu có trường trống
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng điền đầy đủ thông tin thuốc!")),
      );
      return; // Không gửi yêu cầu API nếu có trường trống
    }

    String url = 'http://192.168.60.152:3000/api/medicines';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ten_thuoc': _medicineNameController.text,
        'thanh_phan': _compositionController.text,
        'cong_dung': _usesController.text,
        'tac_dung_phu': _sideEffectsController.text,
        'hinh_anh': _imageUrlController.text,
        'nha_san_xuat': _manufacturerController.text,
        'danh_gia_tot': double.tryParse(_excellentReviewController.text) ?? 0.0,
        'danh_gia_trung_binh': double.tryParse(_averageReviewController.text) ?? 0.0,
        'danh_gia_kem': double.tryParse(_poorReviewController.text) ?? 0.0,
      }),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusCode == 201 ? 'Thêm thuốc thành công!' : 'Thuốc này đã có!'),
        ),
      );
    }

    if (response.statusCode == 201) {
      _medicineNameController.clear();
      _compositionController.clear();
      _usesController.clear();
      _sideEffectsController.clear();
      _imageUrlController.clear();
      _manufacturerController.clear();
      _excellentReviewController.clear();
      _averageReviewController.clear();
      _poorReviewController.clear();
    }
  }


  Future<void> _addDisease() async {
    // Kiểm tra nếu các trường quan trọng trống
    if (_diseaseNameController.text.isEmpty ||
        _defineController.text.isEmpty ||
        _reasonController.text.isEmpty ||
        _symptomController.text.isEmpty ||
        _diagnoseController.text.isEmpty ||
        _treatmentController.text.isEmpty ) {
      // Thông báo nếu có trường trống
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng điền đầy đủ thông tin bệnh!")),
      );
      return; // Không gửi yêu cầu API nếu có trường trống
    }

    String url = 'http://192.168.60.152:3000/api/diseases';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ten_benh': _diseaseNameController.text,
        'dinh_nghia': _defineController.text,
        'nguyen_nhan': _reasonController.text,
        'trieu_chung': _symptomController.text,
        'chan_doan': _diagnoseController.text,
        'dieu_tri': _treatmentController.text,
      }),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusCode == 201 ? 'Thêm bệnh thành công!' : 'Bệnh này đã có!'),
        ),
      );
    }

    if (response.statusCode == 201) {
      _diseaseNameController.clear();
      _defineController.clear();
      _reasonController.clear();
      _symptomController.clear();
      _diagnoseController.clear();
      _treatmentController.clear();
    }
  }

  Future<void> _uploadFile(BuildContext context, String type) async {
    // Hiển thị hộp thoại xác nhận trước khi tải file
    bool? shouldUpload = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Xác nhận"),
          content: Text("Bạn có chắc chắn muốn tải file lên không?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Người dùng không tải
              },
              child: Text("Không"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Người dùng đồng ý tải
              },
              child: Text("Có"),
            ),
          ],
        );
      },
    );

    // Nếu người dùng đồng ý tải file
    if (shouldUpload != null && shouldUpload) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String url = type == 'medicine'
            ? 'http://192.168.60.152:3000/api/medicines/upload'
            : 'http://192.168.60.152:3000/api/diseases/upload';

        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        var response = await request.send();
        String responseBody = await response.stream.bytesToString();

        try {
          final responseJson = jsonDecode(responseBody);
          String errorMessage = responseJson['message'] ?? 'Tải file thất bại!';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$errorMessage')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tải file thất bại! Lỗi không xác định.')),
            );
          }
        }

        // Làm trống lại trường sau khi tải file thành công
        if (response.statusCode == 201) {
          setState(() {
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không có file nào được chọn')),
          );
        }
      }
    } else {
      // Nếu người dùng chọn không tải file
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn đã hủy tải file')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Cập nhật Thuốc & Bệnh"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Thêm Thuốc"),
              Tab(text: "Thêm Bệnh"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMedicineForm(context),
            _buildDiseaseForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineForm(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(controller: _medicineNameController, decoration: InputDecoration(labelText: "Tên thuốc")),
          TextField(controller: _compositionController, decoration: InputDecoration(labelText: "Thành phần")),
          TextField(controller: _usesController, decoration: InputDecoration(labelText: "Công dụng")),
          TextField(controller: _sideEffectsController, decoration: InputDecoration(labelText: "Tác dụng phụ")),
          TextField(controller: _imageUrlController, decoration: InputDecoration(labelText: "URL Hình ảnh")),
          TextField(controller: _manufacturerController, decoration: InputDecoration(labelText: "Nhà sản xuất")),
          TextField(controller: _excellentReviewController, decoration: InputDecoration(labelText: "Đánh giá xuất sắc (%)"), keyboardType: TextInputType.number),
          TextField(controller: _averageReviewController, decoration: InputDecoration(labelText: "Đánh giá trung bình (%)"), keyboardType: TextInputType.number),
          TextField(controller: _poorReviewController, decoration: InputDecoration(labelText: "Đánh giá kém (%)"), keyboardType: TextInputType.number),
          SizedBox(height: 10),
          ElevatedButton(onPressed: _addMedicine, child: Text("Thêm Thuốc")),
          ElevatedButton(onPressed: () => _uploadFile(context, 'medicine'), child: Text("Tải File Lên")),
        ],
      ),
    );
  }

  Widget _buildDiseaseForm(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(controller: _diseaseNameController, decoration: InputDecoration(labelText: "Tên bệnh")),
          TextField(controller: _defineController, decoration: InputDecoration(labelText: "Định nghĩa")),
          TextField(controller: _reasonController, decoration: InputDecoration(labelText: "Nguyên nhân")),
          TextField(controller: _symptomController, decoration: InputDecoration(labelText: "Triệu chứng")),
          TextField(controller: _diagnoseController, decoration: InputDecoration(labelText: "Chẩn đoán")),
          TextField(controller: _treatmentController, decoration: InputDecoration(labelText: "Điều trị")),
          SizedBox(height: 10),
          ElevatedButton(onPressed: _addDisease, child: Text("Thêm Bệnh")),
          ElevatedButton(onPressed: () => _uploadFile(context, 'disease'), child: Text("Tải File Lên")),
        ],
      ),
    );
  }
}
