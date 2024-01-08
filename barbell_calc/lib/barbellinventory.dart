import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'barbell.dart';

class BarbellInventoryPage extends StatefulWidget {
  const BarbellInventoryPage({super.key});

  @override
  State<BarbellInventoryPage> createState() => _BarbellInventoryPageState();
}

class _BarbellInventoryPageState extends State<BarbellInventoryPage> {
  late List<Barbell> barbells = [];

  @override
  void initState() {
    getBarbells();
    super.initState();
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
  }

  void updateBarbells() {
    getBarbells();
    setState(() {});
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
    getBarbells();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbell Inventory'),
      ),
      body: ListView.builder(
        itemCount: barbells.length,
        itemBuilder: (BuildContext context, int index) {
          return BarbellListItem(
            barbell: barbells[index],
            index: index,
            onDelete: deleteBarbell,
            barbellListLength: barbells.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddBarbell(onSave: updateBarbells)),
            );
          },
          child: const Icon(Icons.add)),
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
            if (barbellListLength==1) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:  const Text('Attention'),
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

class AddBarbell extends StatefulWidget {
  const AddBarbell({super.key, required this.onSave});

  final Function() onSave;

  @override
  State<AddBarbell> createState() => _AddBarbellState();
}

class _AddBarbellState extends State<AddBarbell> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  List<String> widthList = <String>['Standard', 'Olympic'];
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widthList.first;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Barbell'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Barbell Name',
                icon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
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
      ),
      floatingActionButton: FloatingActionButton(
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
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Name cannot be empty!'),
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
            // check if weight is empty
            if (weightController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text('Weight cannot be empty!'),
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
              // check if weight is valid
              if (checkWeightDouble()) {
                saveBarbell();
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Weight is invalid!'),
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
              }
            }
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
