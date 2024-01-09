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
      darkMode = prefs.getBool('darkMode') ?? false;
      followSystemTheme = prefs.getBool('followSystemTheme') ?? false;
      appColor = Color(prefs.getInt('appColor') ?? Colors.blue.value);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            seedColor: appColor, brightness: Brightness.dark),
      ),
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  final List<Widget> pages = [
    const MainPage(),
    const InventoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
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

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   bool darkMode = false;
//   bool followSystem = false;
//   ThemeMode theme = ThemeMode.light;
//   late SharedPreferences prefs;
//
//   Color savedColor = Colors.blue;
//
//   // starting loadSharedPreference()
//   @override
//   void initState() {
//     super.initState();
//     loadSharedPreference();
//   }
//
//   void loadSharedPreference() async {
//     prefs = await SharedPreferences.getInstance();
//     setState(() {
//       // reading darkModeEnabled and save value to variable - if not existing disable dark mode
//       darkMode = prefs.getBool('darkModeEnabled') ?? false;
//
//       // reading darkModeEnabled and save value to variable - if not existing disable system theme
//       followSystem = prefs.getBool('systemThemeEnabled') ?? false;
//
//       // reading selectedColor and save value to variable - if not existing set color blue
//       savedColor = Color(prefs.getInt('selectedColor') ?? Colors.blue.value);
//     });
//   }
//
//   void updateTheme(bool value) {
//     darkMode = value;
//     setTheme();
//     setState(() {});
//   }
//
//   void setSystemTheme(bool value) {
//     followSystem = value;
//     setTheme();
//     setState(() {});
//   }
//
//   void updateColor(Color value) {
//     savedColor = value;
//     setTheme();
//     setState(() {});
//   }
//
//   void setTheme() {
//     loadSharedPreference();
//     if (followSystem) {
//       theme = ThemeMode.system;
//     } else {
//       theme = darkMode ? ThemeMode.dark : ThemeMode.light;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BarbellCalc',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: savedColor),
//         useMaterial3: true,
//       ),
//       darkTheme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//             seedColor: savedColor, brightness: Brightness.dark),
//       ),
//       themeMode: theme,
//       home: MyHomePage(
//         updateTheme: updateTheme,
//         updateColor: updateColor,
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   final Function(bool) updateTheme;
//   final Function(Color) updateColor;
//
//   const MyHomePage(
//       {super.key, required this.updateTheme, required this.updateColor});
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int currentPageIndex = 0;
//   late Function(bool) updateThemeCallback;
//   late Function(bool) updateSystemThemeCallback;
//   late Function(Color) updateColorCallback;
//
//   @override
//   void initState() {
//     super.initState();
//     updateThemeCallback = widget.updateTheme;
//     updateSystemThemeCallback = widget.updateTheme;
//     updateColorCallback = widget.updateColor;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> pages = [
//       const MainPage(),
//       const InventoryPage(),
//       SettingsPage(
//           updateTheme: updateThemeCallback,
//           updateColor: updateColorCallback,
//           followSystemTheme: updateSystemThemeCallback),
//     ];
//
//     return Scaffold(
//       bottomNavigationBar: NavigationBar(
//         onDestinationSelected: (int index) {
//           setState(() {
//             currentPageIndex = index;
//           });
//         },
//         selectedIndex: currentPageIndex,
//         destinations: const <Widget>[
//           NavigationDestination(
//             selectedIcon: Icon(Icons.home),
//             icon: Icon(Icons.home_outlined),
//             label: 'Home',
//           ),
//           NavigationDestination(
//             selectedIcon: Icon(Icons.inventory),
//             icon: Icon(Icons.inventory_2_outlined),
//             label: 'Inventory',
//           ),
//           NavigationDestination(
//             selectedIcon: Icon(Icons.settings),
//             icon: Icon(Icons.settings_outlined),
//             label: 'Settings',
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: currentPageIndex,
//         children: pages,
//       ),
//     );
//   }
// }
