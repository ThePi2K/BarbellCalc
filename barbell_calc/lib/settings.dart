import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) updateTheme;
  final Function(bool) followSystemTheme;
  final Function(Color) updateColor;

  const SettingsPage(
      {super.key,
      required this.updateTheme,
      required this.updateColor,
      required this.followSystemTheme});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool systemTheme = false;
  late SharedPreferences prefs;
  Color currentColor = Colors.blue; // Default color

  void changeColor(Color color) {
    setState(() => currentColor = color);
    // Save the selected color to SharedPreferences
    prefs.setInt('selectedColor', color.value);

    widget.updateColor(currentColor); // Notify main app to update color
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

      // reading systemThemeEnabled and save value to variable
      systemTheme = prefs.getBool('systemThemeEnabled') ?? false;

      // reading selectedColor and save value to variable
      currentColor = Color(prefs.getInt('selectedColor') ?? Colors.blue.value);
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

  void toggleSystemTheme(bool value) async {
    // set bool value
    await prefs.setBool('systemThemeEnabled', value);
    widget.followSystemTheme(value); // Notify main app to update theme
    setState(() {
      systemTheme = value;
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
          const Row(
            children: [
              Icon(Icons.color_lens_outlined),
              SizedBox(
                width: 10,
              ),
              Text('Design', style: TextStyle(fontSize: 25)),
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text('Follow System Theme'),
            trailing: Switch(
              onChanged: toggleSystemTheme,
              value: systemTheme,
            ),
          ),
          //const Divider(),
          Visibility(
            visible: !systemTheme,
            child: ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                onChanged: toggleDarkMode,
                value: darkMode,
              ),
            ),
          ),
          //const Divider(),
          ListTile(
            title: const Text('App Color'),
            trailing: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Pick a color'),
                      content: SingleChildScrollView(
                          child: BlockPicker(
                        pickerColor: currentColor,
                        onColorChanged: (Color color) {
                          currentColor = color;
                        },
                      )),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Save'),
                          onPressed: () {
                            changeColor(currentColor);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.color_lens_outlined),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return currentColor;
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return Colors.black38;
                  },
                ),
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
