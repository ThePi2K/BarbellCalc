import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = Barbell.encode([
      Barbell(id: 1, name: 'Test', weight: 30.0, width: '30mm'),
      Barbell(id: 2, name: 'Test', weight: 30.0, width: '30mm'),
    ]);
    await prefs.setString('barbells_key', encodedData);
    final String? barbellsString = prefs.getString('barbells_key');
    final List<Barbell> barbells = Barbell.decode(barbellsString!);



    setState(() {
      // reformatting text inputs (remove spaces and minus, replace , with .)
      weightController.text = weightController.text
          .replaceAll(" ", "")
          .replaceAll("-", "")
          .replaceAll(",", ".");

      print(barbells.first.name);
    });


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

class Barbell {
  final int id;
  final String name, width;
  final double weight;

  Barbell({
    required this.id,
    required this.name,
    required this.width,
    required this.weight,
  });

  factory Barbell.fromJson(Map<String, dynamic> jsonData) {
    return Barbell(
      id: jsonData['id'],
      name: jsonData['name'],
      width: jsonData['width'],
      weight: jsonData['weight'],
    );
  }

  static Map<String, dynamic> toMap(Barbell barbell) => {
        'id': barbell.id,
        'name': barbell.name,
        'width': barbell.width,
        'weight': barbell.weight,
      };

  static String encode(List<Barbell> musics) => json.encode(
        musics
            .map<Map<String, dynamic>>((music) => Barbell.toMap(music))
            .toList(),
      );

  static List<Barbell> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<Barbell>((item) => Barbell.fromJson(item))
          .toList();
}
