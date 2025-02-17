import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'plate.dart';
import 'barbell.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late List<Barbell> barbells = [];
  late List<Barbell> barbellsOlympic = [];
  late List<Barbell> barbellsStandard = [];

  late List<Plate> plates = [];
  late List<Plate> platesOlympic = [];
  late List<Plate> platesStandard = [];

  late bool standardBarbells = true;
  late bool olympicBarbells = false;

  late bool metricSystem = true;

  @override
  void initState() {
    updatePlates();
    updateBarbells();
    super.initState();
  }

  void updatePlates() {
    getPlates();
    setState(() {});
  }

  void updateBarbells() {
    getBarbells();
    setState(() {});
  }

  void getWidths() async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get available widths
    standardBarbells = prefs.getBool('standardBarbells') ?? true;
    olympicBarbells = prefs.getBool('olympicBarbells') ?? false;

    // get unit system
    metricSystem = prefs.getBool('metricSystem') ?? true;
  }

  void getPlates() async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get plates from SharedPreferences
    final String? platesString = prefs.getString('plates_key');

    // check if Items in List
    if (platesString != null) {
      setState(() {
        // save the plates into the List "plates"
        plates = Plate.decode(platesString);
      });
    }

    // add all barbells to their own list
    platesOlympic =
        plates.where((plates) => plates.width == 'Olympic').toList();
    platesStandard =
        plates.where((plates) => plates.width == 'Standard').toList();

    getWidths();
  }

  void getBarbells() async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get barbells from SharedPreferences
    final String? barbellsString = prefs.getString('barbells_key');

    // check if Items in List
    if (barbellsString != null) {
      setState(() {
        // save the barbells into the List "barbells"
        barbells = Barbell.decode(barbellsString);
      });
    }

    // add all barbells to their own list
    barbellsOlympic =
        barbells.where((barbell) => barbell.width == 'Olympic').toList();
    barbellsStandard =
        barbells.where((barbell) => barbell.width == 'Standard').toList();

    getWidths();
  }

  Future<void> deleteBarbell(Barbell barbellToDelete) async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get barbells from SharedPreferences
    final String? barbellsString = prefs.getString('barbells_key');

    // check if Items in List
    if (barbellsString != null) {
      setState(() {
        // save the barbells into the List "barbells"
        barbells = Barbell.decode(barbellsString);
      });
    }

    // remove barbell from array
    for (int i = barbells.length - 1; i >= 0; i--) {
      Barbell barbell = barbells[i];
      if (barbell.weight == barbellToDelete.weight &&
          barbell.name == barbellToDelete.name &&
          barbell.width == barbellToDelete.width) {
        barbells.removeAt(i);
      }
    }

    // Encode the updated list to a string
    final String encodedData = Barbell.encode(barbells);

    // Write the updated string to 'barbells_key'
    await prefs.setString('barbells_key', encodedData);

    // refresh the list
    updateBarbells();
  }

  Future<void> deletePlate(Plate plateToDelete) async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get barbells from SharedPreferences
    final String? platesString = prefs.getString('plates_key');

    // check if Items in List
    if (platesString != null) {
      setState(() {
        // save the plates into the List "plates"
        plates = Plate.decode(platesString);
      });
    }

    // remove plate from array
    for (int i = plates.length - 1; i >= 0; i--) {
      Plate plate = plates[i];
      if (plate.weight == plateToDelete.weight &&
          plate.width == plateToDelete.width) {
        plates.removeAt(i);
      }
    }

    // Encode the updated list to a string
    final String encodedData = Plate.encode(plates);

    // Write the updated string to 'barbells_key'
    await prefs.setString('plates_key', encodedData);

    // refresh the list
    updatePlates();
  }

  @override
  Widget build(BuildContext context) {
    // first run
    updatePlates();
    updateBarbells();
    return SafeArea(
      child: Scaffold(
          body: InventoryListView(
            barbellListStandard: barbellsStandard,
            barbellListOlympic: barbellsOlympic,
            barbellListAll: barbells,
            plateListStandard: platesStandard,
            plateListOlympic: platesOlympic,
            standardBarbells: standardBarbells,
            olympicBarbells: olympicBarbells,
            metricSystem: metricSystem,
            deletePlate: deletePlate,
            deleteBarbell: deleteBarbell,
            saveBarbell: updateBarbells,
          ),
          floatingActionButton: NewPlateBarbellButton(
            onSavePlate: updatePlates,
            onSaveBarbell: updateBarbells,
            plates: plates,
            barbells: barbells,
          )),
    );
  }
}

class NewPlateBarbellButton extends StatelessWidget {
  const NewPlateBarbellButton({
    super.key,
    required this.onSavePlate,
    required this.onSaveBarbell,
    required this.plates,
    required this.barbells,
  });

  final Function() onSavePlate;
  final Function() onSaveBarbell;
  final List<Plate> plates;
  final List<Barbell> barbells;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .inversePrimary
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.fitness_center,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(AppLocalizations.of(context)!.add_barbell),
                        onTap: () {
                          // Closing PopupMenu
                          Navigator.pop(context);

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CreateBarbell(
                                onSave: onSaveBarbell,
                                barbells: barbells,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .inversePrimary
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      child: ListTile(
                        // leading: const Icon(Icons.radio_button_off),
                        leading: SvgPicture.asset(
                          'assets/icons/plate.svg',
                          height: 30,
                          theme: SvgTheme(
                              currentColor:
                                  Theme.of(context).colorScheme.onSurface),
                          // color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(AppLocalizations.of(context)!.add_plate),
                        onTap: () {
                          // Closing PopupMenu
                          Navigator.pop(context);

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CreatePlate(
                                onSave: onSavePlate,
                                plates: plates,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add));
  }
}

class InventoryButton extends StatelessWidget {
  const InventoryButton({
    super.key,
    required this.title,
    required this.image,
    required this.inventoryPage,
  });

  final String title;
  final String image;
  final Function inventoryPage;

  final double textSize = 60.0;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            inventoryPage(),
          );
        },
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                // adding BlendMode to picture
                Colors.white.withOpacity(0.6),
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Center(
            child: Stack(
              children: [
                // Text Border
                Text(
                  title,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2.0
                      ..color = Colors.white,
                  ),
                ),
                // Text
                Text(
                  title,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CreatePlate extends StatefulWidget {
  const CreatePlate({super.key, required this.onSave, required this.plates});

  final Function() onSave;
  final List<Plate> plates;

  @override
  State<CreatePlate> createState() => _CreatePlateState();
}

class _CreatePlateState extends State<CreatePlate> {
  final TextEditingController weightController = TextEditingController();

  bool standardBarbells = true;
  bool olympicBarbells = false;

  bool metricSystem = true;

  List<String> widthList = [];

  late String dropdownValue = '';

  @override
  void initState() {
    super.initState();
    getBarbellWidths().then((_) {
      if (widthList.isNotEmpty) {
        dropdownValue = widthList.first;
        setState(
            () {}); // Trigger a rebuild to update the UI after dropdownValue is set
      }
    });
  }

  getBarbellWidths() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // reading SharedPreferences and save the values to the variables
    standardBarbells = prefs.getBool('standardBarbells') ?? true;
    olympicBarbells = prefs.getBool('olympicBarbells') ?? false;

    // get unit System
    metricSystem = prefs.getBool('metricSystem') ?? true;

    if (standardBarbells) {
      widthList.add('Standard');
    }
    if (olympicBarbells) {
      widthList.add('Olympic');
    }
  }

  void savePlate() async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get plates from SharedPreferences and save them into the List "plates"
    final String? platesString = prefs.getString('plates_key');
    List<Plate> plates = [];
    plates = Plate.decode(platesString!);

    Plate plateToAdd = Plate(
        weight: double.parse(weightController.text), width: dropdownValue);

    plates.add(plateToAdd);

    // sort plates by weight
    plates.sort((a, b) => b.weight.compareTo(a.weight));

    // Encode the updated list to a string
    final String encodedData = Plate.encode(plates);

    // Write the updated string to 'plates_key'
    await prefs.setString('plates_key', encodedData);

    closeWindow();
    widget.onSave();
  }

  void closeWindow() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  bool checkWeightDouble() {
    try {
      double.parse(weightController.text);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.add_plate),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0,5,0,0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: weightController,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                decoration: InputDecoration(
                  // ignore: prefer_const_constructors
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.plate_weight,
                  icon: const Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.select_width,
                  icon: const Icon(Icons.straighten),
                ),
                value: dropdownValue,
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: widthList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            // reformatting text inputs (remove spaces and minus, replace , with .)
            weightController.text = weightController.text
                .replaceAll(" ", "")
                .replaceAll("-", "")
                .replaceAll(",", ".");

            // check if weight is empty
            if (weightController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                      errorMessage:
                          AppLocalizations.of(context)!.weight_cannot_be_empty);
                },
              );
            } else {
              // check if weight is valid
              if (checkWeightDouble()) {
                Plate plateToAdd = Plate(
                    weight: double.parse(weightController.text),
                    width: dropdownValue);

                // check if plate is already saved
                bool isPlateDouble = widget.plates.any((plate) =>
                    plate.weight == plateToAdd.weight &&
                    plate.width == plateToAdd.width);

                if (isPlateDouble) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ErrorDialog(
                          errorMessage:
                              AppLocalizations.of(context)!.plate_exists);
                    },
                  );
                } else {
                  if (plateToAdd.weight <= 0) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                            errorMessage: AppLocalizations.of(context)!
                                .plate_has_to_weight_more_than_0(
                                    metricSystem ? 'kg' : 'lb'));
                      },
                    );
                  } else {
                    savePlate();
                  }
                }
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ErrorDialog(
                        errorMessage:
                            AppLocalizations.of(context)!.weight_is_invalid);
                  },
                );
              }
            }
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }
}

class CreateBarbell extends StatefulWidget {
  const CreateBarbell(
      {super.key, required this.onSave, required this.barbells});

  final Function() onSave;
  final List<Barbell> barbells;

  @override
  State<CreateBarbell> createState() => _CreateBarbellState();
}

class _CreateBarbellState extends State<CreateBarbell> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  bool standardBarbells = true;
  bool olympicBarbells = false;

  bool metricSystem = true;

  List<String> widthList = [];

  // List<String> widthList = <String>['Standard', 'Olympic'];
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    getBarbellWidths().then((_) {
      if (widthList.isNotEmpty) {
        dropdownValue = widthList.first;
        setState(
            () {}); // Trigger a rebuild to update the UI after dropdownValue is set
      }
    });
  }

  getBarbellWidths() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // reading SharedPreferences and save the values to the variables
    standardBarbells = prefs.getBool('standardBarbells') ?? true;
    olympicBarbells = prefs.getBool('olympicBarbells') ?? false;

    // get unit System
    metricSystem = prefs.getBool('metricSystem') ?? true;

    if (standardBarbells) {
      widthList.add('Standard');
    }
    if (olympicBarbells) {
      widthList.add('Olympic');
    }
  }

  void saveBarbell() async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get barbells from SharedPreferences and save them into the List "barbells"
    final String? barbellsString = prefs.getString('barbells_key');
    List<Barbell> barbells = [];
    barbells = Barbell.decode(barbellsString!);

    Barbell barbellToAdd = Barbell(
        name: nameController.text,
        weight: double.parse(weightController.text),
        width: dropdownValue);

    // add barbell to List (on top)
    barbells.insert(0, barbellToAdd);

    // Encode the updated list to a string
    final String encodedData = Barbell.encode(barbells);

    // Write the updated string to 'barbells_key'
    await prefs.setString('barbells_key', encodedData);

    closeWindow();
    widget.onSave();
  }

  void closeWindow() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  bool checkWeightDouble() {
    try {
      double.parse(weightController.text);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.add_barbell),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0,5,0,0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.barbell_name,
                  icon: const Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: weightController,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.barbell_weight,
                  icon: const Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.select_width,
                  icon: const Icon(Icons.straighten),
                ),
                value: dropdownValue,
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: widthList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            // reformatting text inputs (remove spaces and minus, replace , with .)
            weightController.text = weightController.text
                .replaceAll(" ", "")
                .replaceAll("-", "")
                .replaceAll(",", ".");

            // check if name is empty
            if (nameController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                      errorMessage:
                          AppLocalizations.of(context)!.name_cannot_be_empty);
                },
              );
            } else {
              // check if weight is empty
              if (weightController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ErrorDialog(
                        errorMessage: AppLocalizations.of(context)!
                            .weight_cannot_be_empty);
                  },
                );
              } else {
                // check if weight is valid
                if (checkWeightDouble()) {
                  Barbell barbellToAdd = Barbell(
                      name: nameController.text,
                      weight: double.parse(weightController.text),
                      width: dropdownValue);

                  // check if barbell is already saved
                  bool isBarbellDouble = widget.barbells.any((barbell) =>
                      barbell.weight == barbellToAdd.weight &&
                      barbell.width == barbellToAdd.width &&
                      barbell.name == barbellToAdd.name);
                  if (isBarbellDouble) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                            errorMessage:
                                AppLocalizations.of(context)!.barbell_exists);
                      },
                    );
                  } else {
                    if (barbellToAdd.weight <= 0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                              errorMessage: AppLocalizations.of(context)!
                                  .barbell_has_to_weight_more_than_0(
                                      metricSystem ? 'kg' : 'lb'));
                        },
                      );
                    } else {
                      saveBarbell();
                    }
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ErrorDialog(
                          errorMessage:
                              AppLocalizations.of(context)!.weight_is_invalid);
                    },
                  );
                }
              }
            }
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    super.dispose();
  }
}

class EditBarbell extends StatefulWidget {
  const EditBarbell({
    super.key,
    required this.barbell,
    required this.barbellList,
    required this.onDelete,
    required this.onSave,
  });

  final Barbell barbell;
  final List<Barbell> barbellList;
  final Function(Barbell) onDelete;
  final Function() onSave;

  @override
  State<EditBarbell> createState() => _EditBarbellState();
}

class _EditBarbellState extends State<EditBarbell> {
  bool standardBarbells = true;
  bool olympicBarbells = false;

  bool metricSystem = true;

  late String dropdownValue;

  List<String> widthList = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getBarbellWidths().then((_) {
      nameController.text = widget.barbell.name;
      weightController.text = widget.barbell.weight.toString();
      dropdownValue = widget.barbell.width;
    });
  }

  getBarbellWidths() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // reading SharedPreferences and save the values to the variables
    standardBarbells = prefs.getBool('standardBarbells') ?? true;
    olympicBarbells = prefs.getBool('olympicBarbells') ?? false;

    // get unit System
    metricSystem = prefs.getBool('metricSystem') ?? true;

    if (standardBarbells) {
      widthList.add('Standard');
    }
    if (olympicBarbells) {
      widthList.add('Olympic');
    }
  }

  bool checkWeightDouble() {
    try {
      double.parse(weightController.text);
      return true;
    } catch (e) {
      return false;
    }
  }

  void saveBarbell() async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get barbells from SharedPreferences and save them into the List "barbells"
    final String? barbellsString = prefs.getString('barbells_key');
    List<Barbell> barbells = [];
    barbells = Barbell.decode(barbellsString!);

    Barbell barbellToAdd = Barbell(
        name: nameController.text,
        weight: double.parse(weightController.text),
        width: dropdownValue);

    // add barbell to List (on top)
    barbells.insert(0, barbellToAdd);

    // Encode the updated list to a string
    final String encodedData = Barbell.encode(barbells);

    // Write the updated string to 'barbells_key'
    await prefs.setString('barbells_key', encodedData);

    closeWindow();
    widget.onSave;
  }

  void closeWindow() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editing_barbell),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0,5,0,0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.barbell_name,
                  icon: const Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: weightController,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.barbell_weight,
                  icon: const Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.select_width,
                  icon: const Icon(Icons.straighten),
                ),
                value: dropdownValue,
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: widthList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            // reformatting text inputs (remove spaces and minus, replace , with .)
            weightController.text = weightController.text
                .replaceAll(" ", "")
                .replaceAll("-", "")
                .replaceAll(",", ".");

            // check if name is empty
            if (nameController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                      errorMessage:
                          AppLocalizations.of(context)!.name_cannot_be_empty);
                },
              );
            } else {
              // check if weight is empty
              if (weightController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ErrorDialog(
                        errorMessage: AppLocalizations.of(context)!
                            .weight_cannot_be_empty);
                  },
                );
              } else {
                Barbell barbellToAdd = Barbell(
                    name: nameController.text,
                    weight: double.parse(weightController.text),
                    width: dropdownValue);

                // check if weight is valid
                if (checkWeightDouble()) {
                  // check if barbell is already saved
                  bool isBarbellDouble = widget.barbellList.any((barbell) =>
                      barbell.weight == barbellToAdd.weight &&
                      barbell.width == barbellToAdd.width &&
                      barbell.name == barbellToAdd.name);

                  if (isBarbellDouble) {
                    // check if barbell is the same as before
                    if (widget.barbell.weight == barbellToAdd.weight &&
                        widget.barbell.width == barbellToAdd.width &&
                        widget.barbell.name == barbellToAdd.name) {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        SystemNavigator.pop();
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                              errorMessage:
                                  AppLocalizations.of(context)!.barbell_exists);
                        },
                      );
                    }
                  } else {
                    if (barbellToAdd.weight <= 0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                              errorMessage: AppLocalizations.of(context)!
                                  .barbell_has_to_weight_more_than_0(
                                      metricSystem ? 'kg' : 'lb'));
                        },
                      );
                    } else {
                      // test if min. 2 barbells have the width of the og barbell
                      int count = 0;
                      bool min2barbellwiththiswidth = false;
                      for (Barbell b in widget.barbellList) {
                        if (b.width == widget.barbell.width) {
                          count++;
                          if (count >= 2) {
                            min2barbellwiththiswidth = true;
                            break;
                          }
                        }
                      }
                      if (widget.barbell.width == barbellToAdd.width) {
                        if (min2barbellwiththiswidth) {
                          widget.onDelete(widget.barbell);
                          saveBarbell();
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorDialog(
                                  errorMessage: AppLocalizations.of(context)!
                                      .at_least_one_barbell(
                                          widget.barbell.width));
                            },
                          );
                        }
                      }
                    }
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ErrorDialog(
                          errorMessage:
                              AppLocalizations.of(context)!.weight_is_invalid);
                    },
                  );
                }
              }
            }
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 60),
      backgroundColor: Colors.redAccent.shade100,
      title: Text(AppLocalizations.of(context)!.error),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class InventoryListView extends StatelessWidget {
  const InventoryListView({
    super.key,
    required this.barbellListStandard,
    required this.barbellListOlympic,
    required this.plateListStandard,
    required this.plateListOlympic,
    required this.deleteBarbell,
    required this.saveBarbell,
    required this.deletePlate,
    required this.olympicBarbells,
    required this.standardBarbells,
    required this.metricSystem,
    required this.barbellListAll,
  });

  final List<Barbell> barbellListStandard;
  final List<Barbell> barbellListOlympic;
  final List<Plate> plateListStandard;
  final List<Plate> plateListOlympic;
  final List<Barbell> barbellListAll;

  final Function(Barbell) deleteBarbell;
  final Function() saveBarbell;
  final Function(Plate) deletePlate;

  final bool olympicBarbells;
  final bool standardBarbells;

  final bool metricSystem;

  @override
  Widget build(BuildContext context) {
    if (!olympicBarbells) {
      barbellListOlympic.clear();
      plateListOlympic.clear();
    }
    if (!standardBarbells) {
      barbellListStandard.clear();
      plateListStandard.clear();
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // const Divider(),
            InventoryListTitle(title: AppLocalizations.of(context)!.barbells),
            for (var index = 0; index < barbellListStandard.length; index++)
              BarbellListItem(
                barbell: barbellListStandard[index],
                barbellListLength: barbellListStandard.length,
                onDelete: deleteBarbell,
                onSave: saveBarbell,
                olympicBarbells: olympicBarbells,
                standardBarbells: standardBarbells,
                metricSystem: metricSystem,
                barbellList: barbellListAll,
              ),
            for (var index = 0; index < barbellListOlympic.length; index++)
              BarbellListItem(
                barbell: barbellListOlympic[index],
                barbellListLength: barbellListOlympic.length,
                onDelete: deleteBarbell,
                onSave: saveBarbell,
                olympicBarbells: olympicBarbells,
                standardBarbells: standardBarbells,
                metricSystem: metricSystem,
                barbellList: barbellListAll,
              ),
            const SizedBox(height: 5),
            const Divider(),
            InventoryListTitle(title: AppLocalizations.of(context)!.plates),
            for (var index = 0; index < plateListStandard.length; index++)
              PlateListItem(
                plate: plateListStandard[index],
                plateListLength: plateListStandard.length,
                onDelete: deletePlate,
                olympicBarbells: olympicBarbells,
                standardBarbells: standardBarbells,
                metricSystem: metricSystem,
              ),
            for (var index = 0; index < plateListOlympic.length; index++)
              PlateListItem(
                plate: plateListOlympic[index],
                plateListLength: plateListOlympic.length,
                onDelete: deletePlate,
                olympicBarbells: olympicBarbells,
                standardBarbells: standardBarbells,
                metricSystem: metricSystem,
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class BarbellListItem extends StatelessWidget {
  const BarbellListItem({
    super.key,
    required this.barbell,
    required this.onDelete,
    required this.onSave,
    required this.barbellListLength,
    required this.olympicBarbells,
    required this.standardBarbells,
    required this.metricSystem,
    required this.barbellList,
  });

  final Barbell barbell;
  final int barbellListLength;
  final Function(Barbell) onDelete;
  final Function() onSave;
  final bool olympicBarbells;
  final bool standardBarbells;
  final bool metricSystem;
  final List<Barbell> barbellList;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(barbell.name),
        subtitle: BarbellListItemSubtitle(
          olympicBarbells: olympicBarbells,
          standardBarbells: standardBarbells,
          metricSystem: metricSystem,
          barbell: barbell,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EditBarbell(
                      barbell: barbell,
                      barbellList: barbellList,
                      onDelete: onDelete,
                      onSave: onSave,
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (barbellListLength == 1) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.attention),
                        content: Text(AppLocalizations.of(context)!
                            .at_least_one_barbell(barbell.width)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.attention),
                        content: Text(AppLocalizations.of(context)!
                            .really_want_to_delete_barbell),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDelete(barbell);
                            },
                            child: Text(AppLocalizations.of(context)!.yes),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context)!.no),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlateListItem extends StatelessWidget {
  const PlateListItem({
    super.key,
    required this.plate,
    required this.onDelete,
    required this.plateListLength,
    required this.olympicBarbells,
    required this.standardBarbells,
    required this.metricSystem,
  });

  final Plate plate;
  final int plateListLength;
  final bool olympicBarbells;
  final bool standardBarbells;
  final bool metricSystem;

  final Function(Plate) onDelete;

  @override
  Widget build(BuildContext context) {
    String weightString = plate.weight.toString();
    if (weightString.endsWith(".0")) {
      weightString = weightString.substring(0, weightString.length - 2);
    }
    weightString += ' ${metricSystem ? 'kg' : 'lb'}';
    if (olympicBarbells & standardBarbells) {
      return Card(
        child: ListTile(
          title: Text(weightString),
          subtitle: Row(
            children: [
              Text(plate.width),
            ],
          ),
          trailing: PlateListItemIconButton(
            plate: plate,
            onDelete: onDelete,
            plateListLength: plateListLength,
          ),
        ),
      );
    } else {
      return Card(
        child: ListTile(
          title: Text(weightString),
          trailing: PlateListItemIconButton(
            plate: plate,
            onDelete: onDelete,
            plateListLength: plateListLength,
          ),
        ),
      );
    }
  }
}

class BarbellListItemSubtitle extends StatelessWidget {
  const BarbellListItemSubtitle({
    super.key,
    required this.olympicBarbells,
    required this.standardBarbells,
    required this.barbell,
    required this.metricSystem,
  });

  final bool olympicBarbells;
  final bool standardBarbells;
  final bool metricSystem;
  final Barbell barbell;

  @override
  Widget build(BuildContext context) {
    String weightString = barbell.weight.toString();
    if (weightString.endsWith(".0")) {
      weightString = weightString.substring(0, weightString.length - 2);
    }
    weightString += ' ${metricSystem ? 'kg' : 'lb'}';
    if (olympicBarbells & standardBarbells) {
      return Row(
        children: [
          Text(weightString),
          const SizedBox(
            width: 20,
          ),
          Text(barbell.width),
        ],
      );
    } else {
      return Text(weightString);
    }
  }
}

class PlateListItemIconButton extends StatelessWidget {
  const PlateListItemIconButton({
    super.key,
    required this.plate,
    required this.onDelete,
    required this.plateListLength,
  });

  final Plate plate;
  final Function(Plate) onDelete;
  final int plateListLength;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        if (plateListLength == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.attention),
                content: Text(AppLocalizations.of(context)!
                    .at_least_one_plate(plate.width)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.attention),
                content: Text(
                    AppLocalizations.of(context)!.really_want_to_delete_plate),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete(plate);
                    },
                    child: Text(AppLocalizations.of(context)!.yes),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.no),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }
}

class InventoryListTitle extends StatelessWidget {
  const InventoryListTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
