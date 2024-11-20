import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'screens/landing_page.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoe World',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LandingPage(), // Set LandingPage as the initial screen
    );
  }
}