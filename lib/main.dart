import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'database_helper.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
//import 'screens/training_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/account_screen.dart';
import 'home.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/recipe_list_screen_updated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP');
  // Web環境ではsqfliteが動作しないため、モバイル・デスクトップのみでDB初期化
  //if (!kIsWeb) {
    //await DatabaseHelper.instance.ensureDefaultData();
  //}
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _handleThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuscleRecipe',
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: AuthWrapper(
        themeMode: _themeMode,
        onThemeModeChanged: _handleThemeModeChanged,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const AuthWrapper(
      {super.key, required this.themeMode, required this.onThemeModeChanged});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  static const String _loginStatusKey = 'isLoggedIn';
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getBool(_loginStatusKey) ?? false;
    if (mounted) {
      setState(() {
        _isLoggedIn = savedStatus;
        _isInitialized = true;
      });
    }
  }

  Future<void> _handleLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginStatusKey, true);
    if (mounted) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginStatusKey, false);
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return LoginScreen(onLoginSuccess: _handleLoginSuccess);
    }
    return MainApp(
      onLogout: _handleLogout,
      currentThemeMode: widget.themeMode,
      onThemeModeChanged: widget.onThemeModeChanged,
    );
  }
}

class MainApp extends StatefulWidget {
  final VoidCallback onLogout;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const MainApp({
    super.key,
    required this.onLogout,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const HomePage(),
      const RecipeListScreen(),
      const InventoryScreen(),
      AccountScreen(
        onLogout: widget.onLogout,
        currentThemeMode: widget.currentThemeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    // スマホ対応：最大幅を設定
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: screens[_selectedIndex],
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
