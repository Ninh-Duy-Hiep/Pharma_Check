import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_check/presentation/screens/login_screen.dart';
import 'package:pharma_check/presentation/screens/register_screen.dart';
import 'package:pharma_check/presentation/widgets/bottom_nav_bar.dart';
import 'package:pharma_check/presentation/providers/dark_mode_provider.dart';
import 'package:pharma_check/presentation/providers/auth_provider.dart';
import 'package:pharma_check/presentation/providers/favoriteMedicine_provider.dart';

class MyApp extends StatefulWidget {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  String? initialRoute;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

Future<void> _checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? role = prefs.getString('role');
  String? username = prefs.getString('username');
  int? userId = prefs.getInt('user_id');

  print("🔹 App - Kiểm tra trạng thái đăng nhập");
  print("🔹 App - Token: $token");
  print("🔹 App - Role: $role");
  print("🔹 App - Username: $username");
  print("🔹 App - User ID: $userId");

  if (token != null) {
    if (mounted) {
      Provider.of<AuthProvider>(context, listen: false).setAuth(token, role, username, userId);
    }
    initialRoute = '/home';

    if (userId != null) {
      print("🔹 App - Gọi loadFavorites với userId: $userId");
      Provider.of<FavoriteMedicineProvider>(context, listen: false).loadFavorites();
    } else {
      print("❌ App - userId là null, không thể load favorites");
    }
  } else {
    print("🔹 App - Không tìm thấy token, chuyển đến màn hình login");
    initialRoute = '/login';
  }

  if (mounted) {
    setState(() {
      _isLoading = false;
    });
  }
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

    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            scaffoldMessengerKey: MyApp.scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: Provider.of<DarkModeProvider>(context).isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: initialRoute,
            routes: {
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
              '/home': (context) => BottomNavWrapper(role: authProvider.role ?? "user"),
            },
          );
        },
      ),
    );
  }
}
