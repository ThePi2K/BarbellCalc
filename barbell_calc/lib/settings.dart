import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  // final Function(bool) updateTheme;
  // final Function(bool) followSystemTheme;
  // final Function(Color) updateColor;

  const SettingsPage({
    super.key,
    // required this.updateTheme,
    // required this.updateColor,
    // required this.followSystemTheme
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences prefs;

  bool standardBarbells = true;
  bool olympicBarbells = false;
  bool darkMode = false;
  bool followSystemTheme = false;
  Color appColor = Colors.blue;

  // starting loadSharedPreference()
  @override
  void initState() {
    super.initState();
    loadSharedPreference();
  }

  void loadSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      // reading SharedPreferences and save the values to the variables
      standardBarbells = prefs.getBool('standardBarbells') ?? true;
      olympicBarbells = prefs.getBool('olympicBarbells') ?? false;
      darkMode = prefs.getBool('darkMode') ?? false;
      followSystemTheme = prefs.getBool('followSystemTheme') ?? false;
      appColor = Color(prefs.getInt('appColor') ?? Colors.blue.value);
    });
  }

  void toggleStandardBarbells(bool value) async {
    if (olympicBarbells) {
      // set bool value
      await prefs.setBool('standardBarbells', value);
      setState(() {
        standardBarbells = value;
      });
    }
  }

  void toggleOlympicBarbells(bool value) async {
    if (standardBarbells) {
      // set bool value
      await prefs.setBool('olympicBarbells', value);
      setState(() {
        olympicBarbells = value;
      });
    }
  }

  void toggleDarkMode(bool value) async {
    // set bool value
    await prefs.setBool('darkMode', value);
    setState(() {
      darkMode = value;
    });
  }

  void toggleFollowSystemTheme(bool value) async {
    // set bool value
    await prefs.setBool('followSystemTheme', value);
    setState(() {
      followSystemTheme = value;
      darkMode = false;
    });
  }

  void changeColor(Color value) async {
    // set Color value
    await prefs.setInt('appColor', value.value);
    setState(() {
      appColor = value;
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
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text('Design', style: TextStyle(fontSize: 20)),
          ),
          ListTile(
            title: const Text('Follow System Theme'),
            trailing: Switch(
              onChanged: toggleFollowSystemTheme,
              value: followSystemTheme,
            ),
          ),
          Visibility(
            visible: !followSystemTheme,
            child: ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                onChanged: toggleDarkMode,
                value: darkMode,
              ),
            ),
          ),
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
                        pickerColor: appColor,
                        onColorChanged: (Color color) {
                          appColor = color;
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
                            changeColor(appColor);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.color_lens_outlined),
              color: appColor,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(appColor),
                foregroundColor:
                    MaterialStateProperty.all(Colors.white.withOpacity(0.75)),
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text('Sleeve Diameters', style: TextStyle(fontSize: 20)),
          ),
          ListTile(
            title: const Text('Standard Barbells'),
            subtitle: const Text('Ø 30 mm'),
            trailing: Switch(
              onChanged: (value) {
                toggleStandardBarbells(value);
              },
              value: standardBarbells,
            ),
          ),
          ListTile(
            title: const Text('Olympic Barbells'),
            subtitle: const Text('Ø 50 mm'),
            trailing: Switch(
              onChanged: (value) {
                toggleOlympicBarbells(value);
              },
              value: olympicBarbells,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
