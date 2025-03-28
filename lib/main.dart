import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:pharma_check/presentation/providers/label_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pharma_check/app.dart';
import 'package:pharma_check/presentation/providers/dark_mode_provider.dart';
import 'package:pharma_check/presentation/providers/auth_provider.dart';
import 'package:pharma_check/presentation/providers/favoriteMedicine_provider.dart';
import 'package:pharma_check/presentation/providers/register_provider.dart';
import 'package:pharma_check/presentation/providers/favoriteDisease_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope( 
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (context) => DarkModeProvider()),
          provider.ChangeNotifierProvider(create: (context) => AuthProvider()),
          provider.ChangeNotifierProvider(create: (context) => FavoriteMedicineProvider()),
          provider.ChangeNotifierProvider(create: (context) => RegisterProvider()),
          provider.ChangeNotifierProvider(create: (context) => LabelProvider()),
          provider.ChangeNotifierProvider(create: (context) => FavoriteDiseaseProvider()),
        ],
        child: MyApp(),
      ),
    ),
  );
}
