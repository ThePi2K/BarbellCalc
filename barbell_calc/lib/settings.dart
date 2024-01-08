import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) updateTheme;

  const SettingsPage({super.key, required this.updateTheme});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  late SharedPreferences prefs;
  Color currentColor = Colors.blue; // Default color

  void changeColor(Color color) {
    setState(() => currentColor = color);
    // Save the selected color to SharedPreferences or use it as needed
    // For example:
    // prefs.setInt('selectedColor', color.value);
    // Then retrieve it later using:
    // Color savedColor = Color(prefs.getInt('selectedColor') ?? Colors.blue.value);
  }

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
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const Icon(Icons.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const Divider(),
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              onChanged: toggleDarkMode,
              value: darkMode,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Pick a color'),
            trailing: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Pick a color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: currentColor,
                          onColorChanged: changeColor,
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Done'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Save the selected color to SharedPreferences or use it as needed
                            // For example:
                            // prefs.setInt('selectedColor', currentColor.value);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Choose'),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
