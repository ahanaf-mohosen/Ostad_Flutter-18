import 'package:flutter/material.dart';
import 'package:contact_management_app/screens/add_edit_contact_screen.dart';
import 'package:contact_management_app/screens/contact_list_screen.dart';
import 'package:contact_management_app/screens/favorites_screen.dart';
import 'package:contact_management_app/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D5FEF),
          primary: const Color(0xFF5D5FEF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5D5FEF),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF5D5FEF),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5D5FEF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D5FEF),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => ContactListScreen(
              onThemeChanged: toggleTheme,
              themeMode: _themeMode,
            ),
          );
        } else if (settings.name == '/favorites') {
          return MaterialPageRoute(
            builder: (context) => const FavoritesScreen(),
          );
        } else if (settings.name == '/settings') {
          return MaterialPageRoute(
            builder: (context) => SettingsScreen(
              onThemeChanged: toggleTheme,
              themeMode: _themeMode,
            ),
          );
        } else if (settings.name == '/add') {
          return MaterialPageRoute(
            builder: (context) => const AddEditContactScreen(),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
