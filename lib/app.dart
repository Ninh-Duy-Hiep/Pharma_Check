import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_check/presentation/screens/login_screen.dart';
import 'package:pharma_check/presentation/screens/register_screen.dart';
import 'package:pharma_check/presentation/widgets/bottom_nav_bar.dart';
import 'package:pharma_check/presentation/providers/dark_mode_provider.dart';
import 'package:pharma_check/presentation/providers/auth_provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('role');
    print("User role: $role");
    String? username = prefs.getString('username'); // Lấy username

    Provider.of<AuthProvider>(context, listen: false).setAuth(token, role, username);

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: Provider.of<DarkModeProvider>(context).isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: authProvider.isLoggedIn ? '/home' : '/login',
          routes: {
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/home': (context) => BottomNavWrapper(role: authProvider.role ?? "user"), // Truyền role từ AuthProvider
          },
        );
      },
    );
  }
}
