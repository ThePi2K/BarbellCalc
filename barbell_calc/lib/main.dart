import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'inventory.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;
  ThemeMode theme = ThemeMode.light;
  late SharedPreferences prefs;

  // starting loadSharedPreference()
  @override
  void initState() {
    super.initState();
    loadSharedPreference();
  }

  void loadSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      // reading darkModeEnabled and save value to variable
      darkMode = prefs.getBool('darkModeEnabled') ?? false;
      // set theme based of bool
      if (darkMode) {
        theme = ThemeMode.dark;
      } else {
        theme = ThemeMode.light;
      }
    });
  }

  void updateTheme(bool value) {
    setState(() {
      darkMode = value;
      theme = value ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarbellCalc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: theme,
      home: MyHomePage(updateTheme: updateTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(bool) updateTheme;

  const MyHomePage({Key? key, required this.updateTheme}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  late Function(bool) updateThemeCallback;

  @override
  void initState() {
    super.initState();
    updateThemeCallback = widget.updateTheme;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const MainPage(),
      const InventoryPage(),
      SettingsPage(updateTheme: updateThemeCallback),
    ];

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
