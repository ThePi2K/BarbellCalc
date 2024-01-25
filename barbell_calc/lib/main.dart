import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  String appLanguage = 'en';

  final String systemLanguage =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final List<String> supportedLanguages = ['en', 'de'];

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

      // get language
      if (prefs.getString('sysLanguage') != systemLanguage) {
        prefs.setString('appLanguage', 'sys');
      }
      if (prefs.getString('appLanguage') == 'sys') {
        appLanguage = systemLanguage;
      } else {
        appLanguage = prefs.getString('appLanguage')!;
      }
      if (!supportedLanguages.contains(appLanguage)){
        appLanguage = 'en';
      }

      // set system language
      prefs.setString('sysLanguage', systemLanguage);
    });
  }

  MaterialApp buildMyApp() {
    ThemeMode themeMode;
    loadSharedPreference();

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale(appLanguage),
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
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

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
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
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: const Icon(Icons.home),
            icon: const Icon(Icons.home_outlined),
            label: AppLocalizations.of(context)!.home,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.inventory),
            icon: const Icon(Icons.inventory_2_outlined),
            label: AppLocalizations.of(context)!.inventory,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.settings),
            icon: const Icon(Icons.settings_outlined),
            label: AppLocalizations.of(context)!.settings,
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
