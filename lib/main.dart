import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/training_screen.dart';
import 'screens/recipe_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/account_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuscleRecipe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TrainingScreen(),
    const RecipeScreen(),
    const InventoryScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // スマホ対応：最大幅を設定
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'トレーニング',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'レシピ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: '在庫管理',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'アカウント',
            ),
          ],
        ),
      ),
    );
  }
}
