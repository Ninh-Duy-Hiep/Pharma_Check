import 'package:flutter/material.dart';
import 'package:pharma_check/presentation/screens/search_screen.dart';
import 'package:pharma_check/presentation/screens/saved_screen.dart';
import 'package:pharma_check/presentation/widgets/bottom_nav_bar.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavWrapper(),
    );
  }
}
