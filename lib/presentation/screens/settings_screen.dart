import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chưa có dữ liệu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          // Text(
          //   'Bạn chưa lưu thông tin nào ở đây',
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: Colors.grey,
          //   ),
          // ),
        ],
      ),
    );
  }
}
