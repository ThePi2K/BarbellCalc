import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'barbell.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        leading: const Icon(Icons.inventory),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InventoryButton(
              title: 'Barbells',
              image: 'assets/barbell_bing.jpeg',
              inventoryPage: () => MaterialPageRoute(
                  builder: (context) => const BarbellInventoryPage()),
            ),
            const SizedBox(height: 15),
            InventoryButton(
              title: 'Plates',
              image: 'assets/plates_bing.jpeg',
              inventoryPage: () => MaterialPageRoute(
                  builder: (context) => const PlateInventoryPage()),
            ),
          ],
        ),
      ),
    );
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

class BarbellInventoryPage extends StatelessWidget {
  const BarbellInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbell Inventory'),
      ),
      body: const Placeholder(),
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

class PlateInventoryPage extends StatelessWidget {
  const PlateInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plate Inventory'),
      ),
      body: const Placeholder(),
      floatingActionButton:
          const FloatingActionButton(onPressed: null, child: Icon(Icons.add)),
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

  Future<void> saveBarbell() async {
    // reformatting text inputs (remove spaces and minus, replace , with .)
    weightController.text = weightController.text
        .replaceAll(" ", "")
        .replaceAll("-", "")
        .replaceAll(",", ".");

    // // get SharedPreferences Instance
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // // convert barbell list to string array
    // final String encodedData = Barbell.encode([
    //   Barbell(id: 1, name: 'Test', weight: 30.0, width: '30mm'),
    //   Barbell(id: 2, name: 'Test', weight: 30.0, width: '30mm'),
    // ]);
    // // write string array to barbells_key
    // await prefs.setString('barbells_key', encodedData);
    // // get string array from barbells_key
    // final String? barbellsString = prefs.getString('barbells_key');
    // // convert string array to barbell list
    // final List<Barbell> barbells = Barbell.decode(barbellsString!);

    // Get SharedPreferences Instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get existing barbells or initialize an empty list
    final String? barbellsString = prefs.getString('barbells_key');
    List<Barbell> barbells = [];
    if (barbellsString != null) {
      barbells = Barbell.decode(barbellsString);
    }

    // Create a new Barbell and add it to the list
    Barbell newBarbell =
        Barbell(name: 'New Barbell', weight: 40.0, width: '40mm');
    barbells.add(newBarbell);

    // Encode the updated list to a string
    final String encodedData = Barbell.encode(barbells);

    // Write the updated string to 'barbells_key'
    await prefs.setString('barbells_key', encodedData);

    // Confirmation message
    print('New barbell added successfully!');

    setState(() {});
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
