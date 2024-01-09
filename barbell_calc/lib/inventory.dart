import 'package:flutter/material.dart';
import 'barbellinventory.dart';
import 'plateinventory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plate.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
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
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: const Text('add Barbell'),
                        onTap: () {
                          // Start BarbellInventoryPage
                          MaterialPageRoute(
                              builder: (context) =>
                                  const BarbellInventoryPage());
                          // Closing PopupMenu
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.radio_button_checked),
                        title: const Text('add Plate'),
                        onTap: () {
                          // Start PlateInventoryPage

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddPlate(onSave: updatePlates)),
                          );
                          // Closing PopupMenu
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.add)));
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
