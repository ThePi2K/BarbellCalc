import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plate.dart';

class PlateInventoryPage extends StatefulWidget {
  const PlateInventoryPage({super.key});

  @override
  State<PlateInventoryPage> createState() => _PlateInventoryPageState();
}

class _PlateInventoryPageState extends State<PlateInventoryPage> {
  late List<Plate> plates = [];

  @override
  void initState() {
    getPlates();
    super.initState();
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

  void updatePlates() {
    getPlates();
    setState(() {});
  }

  Future<void> deletePlate(int index) async {
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

    // remove plate from array
    plates.remove(plates[index]);

    // Encode the updated list to a string
    final String encodedData = Plate.encode(plates);

    // Write the updated string to 'plates_key'
    await prefs.setString('plates_key', encodedData);

    // refresh the list
    updatePlates();
  }

  @override
  Widget build(BuildContext context) {
    getPlates();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plate Inventory'),
      ),
      body: ListView(
        children: [
          ExpansionTile(title: const Text('50'), children: [
            PlateListView(plates: plates, deletePlate: deletePlate)
          ]),
          ExpansionTile(title: const Text('50'), children: [
            PlateListView(plates: plates, deletePlate: deletePlate)
          ]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddPlate(onSave: updatePlates)),
            );


          },
          child: const Icon(Icons.add)),
    );
  }
}

class PlateListView extends StatelessWidget {
  const PlateListView(
      {super.key, required this.plates, required this.deletePlate});

  final List<Plate> plates;
  final Function(int) deletePlate;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,

      itemCount: plates.length,
      itemBuilder: (BuildContext context, int index) {
        return PlateListItem(
          plate: plates[index],
          index: index,
          onDelete: deletePlate,
          plateListLength: plates.length,
        );
      },
    );
  }
}

class PlateListItem extends StatelessWidget {
  const PlateListItem({
    super.key,
    required this.plate,
    required this.index,
    required this.onDelete,
    required this.plateListLength,
  });

  final Plate plate;
  final int index;
  final int plateListLength;
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
            plate.width,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        title: Text(plate.weight.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            if (plateListLength == 1) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Attention'),
                    content: const Text('You need at least one plate!'),
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

class AddPlate extends StatefulWidget {
  const AddPlate({super.key, required this.onSave});

  final Function() onSave;

  @override
  State<AddPlate> createState() => _AddPlateState();
}

class _AddPlateState extends State<AddPlate> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
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
      ),
      floatingActionButton: FloatingActionButton(
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
                  return const ErrorDialog(errorMessage: 'Weight is invalid!');
                },
              );
            }
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  @override
  void dispose() {
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
