import 'package:flutter/material.dart';
import './favoriteDisease_screen.dart';
import './favoriteMedicine_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Số lượng tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách yêu thích'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Thuốc'),
              Tab(text: 'Bệnh'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FavoriteMedicineScreen(), // Màn hình Thuốc
            FavoriteDiseaseScreen(),  // Màn hình Bệnh
          ],
        ),
      ),
    );
  }
}