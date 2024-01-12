import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.updateTheme,});

   final VoidCallback updateTheme;

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

    // set theme in main
    widget.updateTheme;
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

  Color darkenColor(Color color, [double factor = 0.1]) {
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    if (((color.red == 0) &
            (color.green == 0) &
            (color.blue == 0)) | // if black
        ((color.red == 63) &
            (color.green == 81) &
            (color.blue == 181)) | // or dark blue
        ((color.red == 103) &
            (color.green == 58) &
            (color.blue == 183))) // or violet
    {
      return Colors.white;
    } else {
      red = (red * (1 - factor)).round().clamp(0, 255);
      green = (green * (1 - factor)).round().clamp(0, 255);
      blue = (blue * (1 - factor)).round().clamp(0, 255);

      return Color.fromARGB(color.alpha, red, green, blue);
    }
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
          const SettingsTitle(
              title: 'App Design', subtitle: 'Customize the app theme'),
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
                    MaterialStateProperty.all(darkenColor(appColor, 0.5)),
              ),
            ),
          ),
          const Divider(),
          const SettingsTitle(
              title: 'Barbell Sleeve Diameters',
              subtitle: 'Choose at least one barbell type'),
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

class SettingsTitle extends StatelessWidget {
  const SettingsTitle({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Text(subtitle, style: const TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
