import 'package:flutter/material.dart';
import 'package:pharma_check/presentation/screens/settings_screen.dart';
import 'package:pharma_check/presentation/screens/search_screen.dart';
import 'package:pharma_check/presentation/screens/favorite_screen.dart';
import 'package:pharma_check/presentation/screens/update_screen.dart';
import 'package:pharma_check/presentation/screens/chatbot_screen.dart';
import 'package:provider/provider.dart';
import 'package:pharma_check/presentation/providers/dark_mode_provider.dart';
import 'package:pharma_check/presentation/providers/auth_provider.dart';

class BottomNavWrapper extends StatefulWidget {
  final String role;
  BottomNavWrapper({required this.role});

  @override
  _BottomNavWrapperState createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var darkModeProvider = Provider.of<DarkModeProvider>(context);
    bool isDarkMode = darkModeProvider.isDarkMode;

    // ✅ Nếu chưa đăng nhập, điều hướng về trang login ngay lập tức
    if (!authProvider.isLoggedIn) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator())); // Placeholder trong lúc điều hướng
    }

    // ✅ Tạo danh sách màn hình đúng với số lượng tab
    List<Widget> screens = [
      SearchScreen(),
      FavoriteScreen(),
      ChatbotScreen(),
      SettingsScreen(),
    ];

    if (widget.role.trim().toLowerCase() == "admin") {
      screens.insert(2, UpdateScreen());
    }

    // ✅ Đảm bảo currentIndex luôn hợp lệ
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    // ✅ Danh sách Bottom Navigation Bar Items phải khớp với danh sách màn hình
    List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Saved"),
      if (widget.role.trim().toLowerCase() == "admin")
        BottomNavigationBarItem(icon: Icon(Icons.update), label: "Update"),
      BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chatbot"),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        selectedItemColor: isDarkMode ? Colors.tealAccent : Colors.blue,
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey,
        items: navItems,
      ),
    );
  }
}
