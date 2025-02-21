import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'medicine_detail_screen.dart';

class MedicineListScreen extends StatefulWidget {
  final String? searchTerm;

  MedicineListScreen({Key? key, this.searchTerm}) : super(key: key);

  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  List medicines = [];
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    if (widget.searchTerm != null && widget.searchTerm!.trim().isNotEmpty) {
      searchMedicines(widget.searchTerm!);
    } else {
      fetchMedicines(currentPage);
    }
  }

  Future<void> fetchMedicines(int page) async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/medicines/paginated?page=$page'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        medicines = data['data'];
        currentPage = data['currentPage'];
        totalPages = data['totalPages'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Xử lý lỗi nếu cần
    }
  }

  Future<void> searchMedicines(String keyword) async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/medicines/search?searchTerm=$keyword'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        // Giả sử API search trả về kết quả trong trường 'data'
        medicines = data['data'];
        // Không cần phân trang khi tìm kiếm
        currentPage = 1;
        totalPages = 1;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Xử lý lỗi nếu cần
    }
  }

  Widget buildPagination() {
    // Nếu đang tìm kiếm, không hiển thị thanh phân trang.
    if (widget.searchTerm != null && widget.searchTerm!.trim().isNotEmpty) {
      return SizedBox.shrink();
    }

    List<Widget> pageButtons = [];
    const int maxButtons = 3;
    int startPage, endPage;

    if (totalPages <= maxButtons) {
      startPage = 1;
      endPage = totalPages;
    } else {
      startPage = currentPage - 1;
      endPage = currentPage + 1;
      if (startPage < 1) {
        endPage += (1 - startPage);
        startPage = 1;
      }
      if (endPage > totalPages) {
        startPage -= (endPage - totalPages);
        endPage = totalPages;
      }
    }

    pageButtons.add(
      IconButton(
        icon: Icon(Icons.arrow_back, size: 20),
        padding: EdgeInsets.symmetric(horizontal: 4),
        constraints: BoxConstraints(),
        onPressed: currentPage > 1 ? () => fetchMedicines(currentPage - 1) : null,
      ),
    );

    if (startPage > 1) {
      pageButtons.add(
        TextButton(
          onPressed: () => fetchMedicines(1),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            minimumSize: Size(30, 30),
          ),
          child: Text("1", style: TextStyle(color: Colors.black, fontSize: 14)),
        ),
      );
      if (startPage > 2) {
        pageButtons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text("...", style: TextStyle(color: Colors.black, fontSize: 14)),
          ),
        );
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        TextButton(
          onPressed: () => fetchMedicines(i),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            minimumSize: Size(30, 30),
          ),
          child: Text(
            "$i",
            style: TextStyle(
              fontSize: 14,
              fontWeight: currentPage == i ? FontWeight.bold : FontWeight.normal,
              color: currentPage == i ? Colors.blue : Colors.black,
            ),
          ),
        ),
      );
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageButtons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text("...", style: TextStyle(color: Colors.black, fontSize: 14)),
          ),
        );
      }
      pageButtons.add(
        TextButton(
          onPressed: () => fetchMedicines(totalPages),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            minimumSize: Size(30, 30),
          ),
          child: Text("$totalPages", style: TextStyle(color: Colors.black, fontSize: 14)),
        ),
      );
    }

    pageButtons.add(
      IconButton(
        icon: Icon(Icons.arrow_forward, size: 20),
        padding: EdgeInsets.symmetric(horizontal: 4),
        constraints: BoxConstraints(),
        onPressed: currentPage < totalPages ? () => fetchMedicines(currentPage + 1) : null,
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: pageButtons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return Card(
                child: SizedBox(
                  height: 100,
                  child: ListTile(
                    leading: Image.network(
                      medicine['image_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(medicine['medicine_name']),
                    subtitle: Text(
                      medicine['uses'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicineDetailScreen(medicine: medicine),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        // Chỉ hiển thị phân trang nếu không phải kết quả tìm kiếm
        if (widget.searchTerm == null || widget.searchTerm!.trim().isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: buildPagination(),
          ),
      ],
    );
  }
}
