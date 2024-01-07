import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'barbell.dart';

class BarbellInventoryPage extends StatefulWidget {
  const BarbellInventoryPage({super.key});

  @override
  State<BarbellInventoryPage> createState() => _BarbellInventoryPageState();
}

class _BarbellInventoryPageState extends State<BarbellInventoryPage> {
  late List<Barbell> barbells; // Liste zum Speichern der Hanteln

  @override
  void initState() {
    super.initState();
    getBarbells(); // Ruft die Methode auf, um die Hanteln zu laden, wenn das Widget initialisiert wird
  }

  // Methode zum Abrufen der Hanteln aus den SharedPreferences
  void getBarbells() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? barbellsString = prefs.getString('barbells_key');

    if (barbellsString != null) {
      setState(() {
        barbells = Barbell.decode(barbellsString);
      });
    } else {
      // no Items in the Barbell List

      List<Barbell> barbells = [];

      // Create a new Barbell and add it to the list
      Barbell newBarbell =
          Barbell(name: 'My first Barbell', weight: 20.0, width: '30mm');
      barbells.add(newBarbell);

      // Encode the updated list to a string
      final String encodedData = Barbell.encode(barbells);

      // Write the updated string to 'barbells_key'
      await prefs.setString('barbells_key', encodedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbell Inventory'),
      ),
      body: ListView.builder(
        itemCount: barbells.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(barbells[index].name),
            subtitle: Text(
                'Weight: ${barbells[index].weight.toString()} Width: ${barbells[index].width}'),
            // Additional information about the barbell can be displayed here
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBarbell()),
            );
          },
          child: const Icon(Icons.add)),
    );
  }
}

class AddBarbell extends StatefulWidget {
  const AddBarbell({super.key});

  @override
  State<AddBarbell> createState() => _AddBarbellState();
}

class _AddBarbellState extends State<AddBarbell> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  List<String> widthList = <String>['30 mm', '50 mm'];
  late String dropdownValue;

  void saveBarbell() async {
    // reformatting text inputs (remove spaces and minus, replace , with .)
    weightController.text = weightController.text
        .replaceAll(" ", "")
        .replaceAll("-", "")
        .replaceAll(",", ".");

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get existing barbells
    final String? barbellsString = prefs.getString('barbells_key');

    List<Barbell> barbells = [];

    // Create a new Barbell and add it to the list
    Barbell newBarbell = Barbell(
        name: nameController.text,
        weight: double.parse(weightController.text),
        width: dropdownValue);
    barbells.add(newBarbell);

    // Encode the updated list to a string
    final String encodedData = Barbell.encode(barbells);

    // Write the updated string to 'barbells_key'
    await prefs.setString('barbells_key', encodedData);

    // setState(() {
    //   Navigator.pop(context);
    //
    //   final _BarbellInventoryPageState? parentState =
    //   context.findAncestorStateOfType<_BarbellInventoryPageState>();
    //   if (parentState != null) {
    //     parentState
    //         .getBarbells(); // Ruft die Methode auf, um die Hanteln neu zu laden
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    String dropdownValue = widthList.first;
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
          onPressed: saveBarbell, child: const Icon(Icons.check)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
