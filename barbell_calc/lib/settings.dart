import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) updateTheme;

  const SettingsPage({Key? key, required this.updateTheme}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
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
    });
  }

  void toggleDarkMode(bool value) async {
    // set bool value
    await prefs.setBool('darkModeEnabled', value);
    widget.updateTheme(value); // Notify main app to update theme
    setState(() {
      darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Dark Mode',
            ),
            SwitchListTile(
              title: const Text('Enable Dark Mode'),
              onChanged: toggleDarkMode,
              value: darkMode,
            ),
          ],
        ),
      ),
    );
  }
}
