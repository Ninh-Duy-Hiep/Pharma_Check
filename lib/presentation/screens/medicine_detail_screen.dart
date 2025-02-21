import 'package:flutter/material.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Map medicine;

  MedicineDetailScreen({required this.medicine});

  @override
  _MedicineDetailScreenState createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  bool isFavorite = false;

  Widget buildRichText(String label, String content) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16, color: Colors.black),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: content,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine['medicine_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Thêm scroll nếu nội dung dài
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh thuốc
              Center(
                child: Image.network(
                  widget.medicine['image_url'],
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              buildRichText('Medicine Name', widget.medicine['medicine_name']),
              SizedBox(height: 8),
              buildRichText('Composition', widget.medicine['composition']),
              SizedBox(height: 8),
              buildRichText('Uses', widget.medicine['uses']),
              SizedBox(height: 8),
              buildRichText('Side Effects', widget.medicine['side_effects']),
              SizedBox(height: 8),
              buildRichText('Manufacturer', widget.medicine['manufacturer']),
              SizedBox(height: 16),
              Text(
                'Evaluate:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              buildRichText('Excellent Review Percent', '${widget.medicine['excellent_review_percent']}%'),
              SizedBox(height: 4),
              buildRichText('Average Review Percent', '${widget.medicine['average_review_percent']}%'),
              SizedBox(height: 4),
              buildRichText('Poor Review Percent', '${widget.medicine['poor_review_percent']}%'),
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
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
      ),
    );
  }
}
