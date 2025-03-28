import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharma_check/presentation/providers/dark_mode_provider.dart';
import 'package:pharma_check/presentation/providers/auth_provider.dart';
import 'package:pharma_check/presentation/providers/favoriteMedicine_provider.dart';
import 'package:pharma_check/presentation/providers/label_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var darkModeProvider = Provider.of<DarkModeProvider>(context);
    var authProvider = Provider.of<AuthProvider>(context);
    bool isDarkMode = darkModeProvider.isDarkMode;
    bool isLoggedIn = authProvider.isLoggedIn;
    String username = authProvider.username ?? "Người dùng";

    return Scaffold(
      appBar: AppBar(title: Text('Cài đặt')),
      body: Column(
        children: [
          if (isLoggedIn)
            Column(
              children: [
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Xin chào, $username!'),
                  subtitle: Text('Tài khoản của bạn'),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    print("🔹 SettingsScreen - Bắt đầu quá trình đăng xuất");
                    Provider.of<FavoriteMedicineProvider>(context, listen: false).clearFavorites();
                    Provider.of<LabelProvider>(context, listen: false).filterByLabel("Tất cả nhãn");
                    await authProvider
                        .logout(); // ✅ Xóa token, role, username, user_id
                    if (!context.mounted) return;

                    Navigator.pushNamedAndRemoveUntil(context, '/login',
                        (route) => false); // ✅ Xóa hết stack và về login
                  },
                  icon: Icon(Icons.logout, color: Colors.white),
                  label:
                      Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text('Đăng ký'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text('Đăng nhập'),
                ),
              ],
            ),
          Divider(),
          SwitchListTile(
            title: Text('Chế độ tối'),
            value: isDarkMode,
            onChanged: (value) {
              darkModeProvider.toggleDarkMode();
            },
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
      ),
    );
  }
}
