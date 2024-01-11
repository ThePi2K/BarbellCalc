import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plate.dart';
import 'barbell.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late List<Plate> plates = [];
  late List<Barbell> barbells = [];
  late List<Barbell> barbellsOlympic = [];
  late List<Barbell> barbellsStandard = [];

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

    // if 0 plates
    if (plates.isEmpty) {
      // Create a new Plate and add it to the list
      plates.add(Plate(weight: 20.0, width: 'Standard'));

      // Encode the updated list to a string
      final String encodedData = Plate.encode(plates);

      // Write the updated string to 'plates_key'
      await prefs.setString('plates_key', encodedData);
    }
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

    // if 0 barbells
    if (barbells.isEmpty) {
      // initialise the list
      // List<Barbell> barbells = [];

      // Create a new Barbell and add it to the list
      barbells.add(
          Barbell(name: 'My first Barbell', weight: 20.0, width: 'Standard'));

      // Encode the updated list to a string
      final String encodedData = Barbell.encode(barbells);

      // Write the updated string to 'barbells_key'
      await prefs.setString('barbells_key', encodedData);
    }

    // add all barbells to their own list
    barbellsOlympic =
        barbells.where((barbell) => barbell.width == 'Olympic').toList();
    barbellsStandard =
        barbells.where((barbell) => barbell.width == 'Standard').toList();
  }

  Future<void> deleteBarbell(int index) async {
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
    barbells.remove(barbells[index]);

    // Encode the updated list to a string
    final String encodedData = Barbell.encode(barbells);

    // Write the updated string to 'barbells_key'
    await prefs.setString('barbells_key', encodedData);

    // refresh the list
    updateBarbells();
  }

  @override
  Widget build(BuildContext context) {
    // first run
    updatePlates();
    updateBarbells();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
          leading: const Icon(Icons.inventory),
        ),
        body: BarbellListView(
            barbellList: barbellsStandard,
            plateList: plates,
            deleteBarbell: deleteBarbell),
        floatingActionButton: NewPlateBarbellButton(
            onSavePlate: updatePlates, onSaveBarbell: updateBarbells));
  }
}

class NewPlateBarbellButton extends StatelessWidget {
  const NewPlateBarbellButton(
      {super.key, required this.onSavePlate, required this.onSaveBarbell});

  final Function() onSavePlate;
  final Function() onSaveBarbell;

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
                        color: Theme.of(context).colorScheme.inversePrimary,
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: const Text('Add Barbell'),
                        onTap: () {
                          // Closing PopupMenu
                          Navigator.pop(context);

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CreateBarbell(onSave: onSaveBarbell);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.radio_button_off),
                        title: const Text('Add Plate'),
                        onTap: () {
                          // Closing PopupMenu
                          Navigator.pop(context);

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CreatePlate(onSave: onSavePlate);
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
  const InventoryButton(
      {super.key,
      required this.title,
      required this.image,
      required this.inventoryPage});

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
  const CreatePlate({super.key, required this.onSave});

  final Function() onSave;

  @override
  State<CreatePlate> createState() => _CreatePlateState();
}

class _CreatePlateState extends State<CreatePlate> {
  final TextEditingController weightController = TextEditingController();

  bool standardBarbells = true;
  bool olympicBarbells = false;

  List<String> widthList = [];

  // List<String> widthList = <String>['Standard', 'Olympic'];
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

    // add plate to List ()
    plates.add(Plate(
        weight: double.parse(weightController.text), width: dropdownValue));

    // sort plates by weight
    //plates.sort((a, b) => a.weight.compareTo(b.weight));
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
      title: const Text('Add Plate'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            // onTapOutside: (event) {
            //   FocusManager.instance.primaryFocus?.unfocus();
            // },
            controller: weightController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Plate Weight',
              icon: Icon(Icons.scale),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Select Width',
              icon: Icon(Icons.straighten),
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
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('CANCEL'),
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
                  return const ErrorDialog(
                      errorMessage: 'Weight cannot be empty!');
                },
              );
            } else {
              // check if weight is valid
              if (checkWeightDouble()) {
                savePlate();
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ErrorDialog(
                        errorMessage: 'Weight is invalid!');
                  },
                );
              }
            }
          },
          child: const Text('SAVE'),
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
  const CreateBarbell({super.key, required this.onSave});

  final Function() onSave;

  @override
  State<CreateBarbell> createState() => _CreateBarbellState();
}

class _CreateBarbellState extends State<CreateBarbell> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  bool standardBarbells = true;
  bool olympicBarbells = false;

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

    // add barbell to List (on top)
    barbells.insert(
        0,
        Barbell(
            name: nameController.text,
            weight: double.parse(weightController.text),
            width: dropdownValue));

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
      title: const Text('Add Barbell'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            // onTapOutside: (event) {
            //   FocusManager.instance.primaryFocus?.unfocus();
            // },
            controller: nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Barbell Name',
              icon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            // onTapOutside: (event) {
            //   FocusManager.instance.primaryFocus?.unfocus();
            // },
            controller: weightController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Barbell Weight',
              icon: Icon(Icons.scale),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Select Width',
              icon: Icon(Icons.straighten),
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
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('CANCEL'),
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
                  return const ErrorDialog(
                      errorMessage: 'Name cannot be empty!');
                },
              );
            } else {
              // check if weight is empty
              if (weightController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ErrorDialog(
                        errorMessage: 'Weight cannot be empty!');
                  },
                );
              } else {
                // check if weight is valid
                if (checkWeightDouble()) {
                  saveBarbell();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ErrorDialog(
                          errorMessage: 'Weight is invalid!');
                    },
                  );
                }
              }
            }
          },
          child: const Text('SAVE'),
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

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
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

class BarbellListView extends StatelessWidget {
  const BarbellListView(
      {super.key,
      required this.barbellList,
      required this.plateList,
      required this.deleteBarbell});

  final List<Barbell> barbellList;
  final List<Plate> plateList;
  final Function(int) deleteBarbell;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hantelscheiben:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          for (var plate in plateList)
            Text('${plate.weight} kg - ${plate.width}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text(
            'Hanteln:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          for (var index = 0; index < barbellList.length; index++)
            BarbellListItem(
              barbell: barbellList[index],
              barbellListLength: barbellList.length,
              onDelete: deleteBarbell,
              index: index,
            ),
        ],
      ),
    );
  }
}

class BarbellListItem extends StatelessWidget {
  const BarbellListItem({
    super.key,
    required this.barbell,
    required this.index,
    required this.onDelete,
    required this.barbellListLength,
  });

  final Barbell barbell;
  final int index;
  final int barbellListLength;
  final Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            barbell.width,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        title: Text(barbell.name),
        subtitle: Text(barbell.weight.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            if (barbellListLength == 1) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Attention'),
                    content: const Text('You need at least one barbell!'),
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
              onDelete(index);
            }
          },
        ),
      ),
    );
  }
}
