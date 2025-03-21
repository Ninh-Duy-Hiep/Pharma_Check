import 'package:flutter/material.dart';
import 'package:pharma_check/presentation/providers/label_provider.dart';
import 'package:provider/provider.dart';
import 'package:pharma_check/app.dart';
import 'package:pharma_check/presentation/providers/dark_mode_provider.dart';
import 'package:pharma_check/presentation/providers/auth_provider.dart';
import 'package:pharma_check/presentation/providers/favorite_provider.dart';
import 'package:pharma_check/presentation/providers/register_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DarkModeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
        ChangeNotifierProvider(create: (context) => RegisterProvider()),
        ChangeNotifierProvider(create: (context) => LabelProvider()),
      ],
      child: MyApp(),
    ),
  );
}
