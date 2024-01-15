import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'inventory.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SharedPreferences prefs;
  bool darkMode = false;
  bool followSystemTheme = false;
  Color appColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    loadSharedPreference();
  }

  void loadSharedPreference() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      // reading SharedPreferences and save the values to the variables
      appColor = Color(prefs.getInt('appColor') ?? Colors.blue.value);
      darkMode = prefs.getBool('darkMode') ?? false;
      followSystemTheme = prefs.getBool('followSystemTheme') ?? false;
    });
  }

  // void updateTheme() {
  //   loadSharedPreference();
  //   setState(() {});
  // }

  MaterialApp buildMyApp() {
    ThemeMode themeMode;

    if (followSystemTheme) {
      themeMode = ThemeMode.system;
    } else {
      themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    }

    return MaterialApp(
      title: 'BarbellCalc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeMode,
      home: HomePage(updateTheme: loadSharedPreference),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMyApp();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.updateTheme,
  });

  final VoidCallback updateTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  late List<Widget> pages; // Declare pages as a late variable

  @override
  void initState() {
    super.initState();
    // Initialize pages in initState
    pages = [
      const MainPage(),
      const InventoryPage(),
      SettingsPage(updateTheme: widget.updateTheme),
    ];
  }

  @override
  Widget build(BuildContext context) {
    widget.updateTheme();
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.inventory),
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
    );
  }
}