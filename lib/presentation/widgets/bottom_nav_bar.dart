import 'package:flutter/material.dart';
import 'package:pharma_check/presentation/screens/settings_screen.dart';
import 'package:pharma_check/presentation/screens/update_screen.dart';
import '../screens/search_screen.dart';
import '../screens/saved_screen.dart';

class BottomNavWrapper extends StatefulWidget {
  @override
  _BottomNavWrapperState createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    SearchScreen(),
    SavedScreen(),
    SettingsScreen(),
    UpdatesScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,  // Gọi hàm thay đổi màn hình
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Tra Cứu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download),
          label: 'Đã Lưu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,  // Gọi hàm chuyển đổi màn hình
    );
  }
}
