import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.updateTheme,
  });

  final VoidCallback updateTheme;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences prefs;

  bool standardBarbells = true;
  bool olympicBarbells = false;
  bool darkMode = false;
  bool metricSystem = true;
  bool followSystemTheme = false;
  Color appColor = Colors.blue;
  String selectedLanguage = 'en';

  final List<String> supportedLanguages = ['en', 'de'];
  final String systemLanguage =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;

  String getDisplayLanguage(String internalLanguage) {
    switch (internalLanguage) {
      case 'en':
        return 'English (English)';
      case 'de':
        return 'German (Deutsch)';
      default:
        return 'English (English)';
    }
  }

  // starting loadSharedPreference()
  @override
  void initState() {
    super.initState();
    loadSharedPreference();
  }

  void loadSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
    print(systemLanguage);
    setState(() {
      // reading SharedPreferences and save the values to the variables
      standardBarbells = prefs.getBool('standardBarbells') ?? true;
      olympicBarbells = prefs.getBool('olympicBarbells') ?? false;
      darkMode = prefs.getBool('darkMode') ?? false;
      followSystemTheme = prefs.getBool('followSystemTheme') ?? false;
      metricSystem = prefs.getBool('metricSystem') ?? true;
      appColor = Color(prefs.getInt('appColor') ?? Colors.blue.value);

      String? selectedLang = prefs.getString('appLanguage');
      selectedLanguage =
          supportedLanguages.contains(selectedLang) ? selectedLang! : 'en';
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
    widget.updateTheme();
  }

  void toggleFollowSystemTheme(bool value) async {
    // set bool value
    await prefs.setBool('followSystemTheme', value);
    await prefs.setBool('darkMode', false);
    setState(() {
      followSystemTheme = value;
      darkMode = false;
    });

    // set theme in main
    widget.updateTheme();
  }

  void changeColor(Color value) async {
    // set Color value
    await prefs.setInt('appColor', value.value);
    setState(() {
      appColor = value;
    });

    // set theme in main
    widget.updateTheme();
  }

  void toggleUnit(bool value) async {
    // set bool value
    await prefs.setBool('metricSystem', value);
    setState(() {
      metricSystem = value;
    });

    // set theme in main
    widget.updateTheme();
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

  void toggleLanguage(String language) async {
    // set String value
    await prefs.setString('appLanguage', language);
    setState(() {
      selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Settings'),
        //   leading: const Icon(Icons.settings),
        // ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          children: <Widget>[
            // const Divider(),
            const SizedBox(height: 10),
            SettingsTitle(
                title: AppLocalizations.of(context)!.appearance,
                subtitle: AppLocalizations.of(context)!.appearance_subtitle),
            ListTile(
              title: Text(AppLocalizations.of(context)!.follow_system_theme),
              trailing: Switch(
                onChanged: toggleFollowSystemTheme,
                value: followSystemTheme,
              ),
            ),
            Visibility(
              visible: !followSystemTheme,
              child: ListTile(
                title: Text(AppLocalizations.of(context)!.dark_mode),
                trailing: Switch(
                  onChanged: toggleDarkMode,
                  value: darkMode,
                ),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.app_color),
              trailing: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.pick_color),
                        content: SingleChildScrollView(
                            child: BlockPicker(
                          pickerColor: appColor,
                          onColorChanged: (Color color) {
                            appColor = color;
                          },
                        )),
                        actions: <Widget>[
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.save),
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
            SettingsTitle(
                title: AppLocalizations.of(context)!.language_and_unit_system,
                subtitle: AppLocalizations.of(context)!
                    .language_and_unit_system_subtitle),
            ListTile(
              title: Text(AppLocalizations.of(context)!.language),
              trailing: DropdownButton<String>(
                value: selectedLanguage,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    toggleLanguage(newValue);
                  }
                },
                items: supportedLanguages
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(getDisplayLanguage(value)),
                  );
                }).toList(),
              ),
            ),
            // const Divider(),
            // const SettingsTitle(
            //     title: 'Unit System',
            //     subtitle: 'Choose between metric and Imperial/US units'),
            ListTile(
              title: metricSystem
                  ? Text(AppLocalizations.of(context)!.metric_system)
                  : Text(AppLocalizations.of(context)!.us_system),
              subtitle: metricSystem
                  ? const Text('mm/kg')
                  : Text(AppLocalizations.of(context)!.inch_pounds),
              trailing: Switch(
                onChanged: (value) {
                  toggleUnit(value);
                },
                value: metricSystem,
              ),
            ),
            const Divider(),
            SettingsTitle(
                title: AppLocalizations.of(context)!.barbell_sleeve_diameters,
                subtitle: AppLocalizations.of(context)!
                    .barbell_sleeve_diameters_subtitle),
            ListTile(
              title: Text(AppLocalizations.of(context)!.standard_barbells),
              subtitle:
                  metricSystem ? const Text('Ø 30 mm') : const Text('Ø 1.18"'),
              trailing: Switch(
                onChanged: (value) {
                  toggleStandardBarbells(value);
                },
                value: standardBarbells,
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.olympic_barbells),
              subtitle:
                  metricSystem ? const Text('Ø 50 mm') : const Text('Ø 2"'),
              trailing: Switch(
                onChanged: (value) {
                  toggleOlympicBarbells(value);
                },
                value: olympicBarbells,
              ),
            ),
            // const Divider(),
          ],
        ),
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
