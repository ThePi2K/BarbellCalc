import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
      darkMode = prefs.getBool('darkModeEnabled') ?? false;
    });
  }

  void toggleDarkMode(bool value) async {
    // set bool value
    await prefs.setBool('darkModeEnabled', value);
    setState(() {
      darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Row(
        children: [
          const Text('Dark Mode'),
          Switch(value: darkMode, onChanged: toggleDarkMode),
          Text(darkMode.toString())
        ],
      ),
    );
  }
}

// class _SettingsPageState extends State<SettingsPage> {
//   late bool isDarkMode;
//   late SharedPreferences _prefs;
//
//   @override
//   void initState() {
//     super.initState();
//     loadPreferences();
//   }
//
//   Future<void> loadPreferences() async {
//     _prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isDarkMode = _prefs.getBool('isDarkMode') ?? false;
//     });
//   }
//
//   Future<void> _toggleDarkMode(bool value) async {
//     setState(() {
//       isDarkMode = value;
//     });
//     await _prefs.setBool('isDarkMode', value);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             const Text(
//               'Dark Mode',
//             ),
//             SwitchListTile(
//               title: const Text('Enable Dark Mode'),
//               onChanged: _toggleDarkMode,
//               value: isDarkMode,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
