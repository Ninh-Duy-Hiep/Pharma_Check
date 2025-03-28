import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:diacritic/diacritic.dart';
import 'dart:convert';
import 'disease_screen_detail.dart';

class DiseaseListScreen extends StatefulWidget {
  final String searchTerm;

  const DiseaseListScreen({Key? key, required this.searchTerm}) : super(key: key);

  @override
  _DiseaseListScreenState createState() => _DiseaseListScreenState();
}

class _DiseaseListScreenState extends State<DiseaseListScreen> {
  List<Map<String, dynamic>> diseases = [];
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> groupedDiseases = {};

  @override
  void initState() {
    super.initState();
    fetchDiseases();
  }

  @override
  void didUpdateWidget(DiseaseListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchTerm != widget.searchTerm) {
      fetchDiseases();
    }
  }

  Future<void> fetchDiseases() async {
    setState(() {
      isLoading = true;
    });

    if (widget.searchTerm.isEmpty) {
      await fetchAllDiseases();
    } else {
      await searchDiseases(widget.searchTerm);
    }
  }

  /// API: Lấy tất cả bệnh
  Future<void> fetchAllDiseases() async {
    String url = 'http://192.168.10.152:3000/api/diseases';
    print('Fetching all diseases from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        processDiseasesResponse(response.body);
      } else {
        throw Exception('Failed to load all diseases');
      }
    } catch (e) {
      print('Error fetching all diseases: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// API: Tìm kiếm bệnh
  Future<void> searchDiseases(String searchTerm) async {
    String url = 'http://192.168.10.152:3000/api/diseases/search?searchTerm=${Uri.encodeComponent(searchTerm)}';
    print('Searching diseases with term: $searchTerm from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        processDiseasesResponse(response.body);
      } else {
        throw Exception('Failed to search diseases');
      }
    } catch (e) {
      print('Error searching diseases: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Xử lý dữ liệu từ API
  void processDiseasesResponse(String responseBody) {
    final Map<String, dynamic> responseData = json.decode(responseBody);
    print('API Response: $responseBody');

    if (!responseData.containsKey('data') || responseData['data'] == null || responseData['data'].isEmpty) {
      print('No diseases found');
      setState(() {
        diseases = [];
        groupedDiseases = {};
        isLoading = false;
      });
      return;
    }

    List<Map<String, dynamic>> fetchedDiseases = List<Map<String, dynamic>>.from(responseData['data']);

    // Sắp xếp danh sách theo bảng chữ cái sau khi bỏ dấu
    fetchedDiseases.sort((a, b) {
      String nameA = removeDiacritics(a['ten_benh'] ?? '').toUpperCase();
      String nameB = removeDiacritics(b['ten_benh'] ?? '').toUpperCase();
      return nameA.compareTo(nameB);
    });

    // Nhóm theo chữ cái đầu tiên
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var disease in fetchedDiseases) {
      String name = removeDiacritics(disease['ten_benh'] ?? '').trim();
      if (name.isNotEmpty) {
        String firstLetter = name[0].toUpperCase();
        grouped.putIfAbsent(firstLetter, () => []);
        grouped[firstLetter]!.add(disease);
      }
    }

    setState(() {
      diseases = fetchedDiseases;
      groupedDiseases = grouped;
      isLoading = false;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : diseases.isEmpty
          ? Center(child: Text("Không tìm thấy bệnh"))
          : ListView(
        children: groupedDiseases.entries.map((entry) {
          String letter = entry.key;
          List<Map<String, dynamic>> diseases = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...diseases.map((disease) {
                String name = disease['ten_benh'] ?? 'Chưa có tên';
                String diseaseId = disease['id'].toString(); // Assuming 'id' is available
                return ListTile(
                  title: Text(name),
                  onTap: () {
                    // Navigate to the disease detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiseaseScreenDetail(diseaseData: disease),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

}
