import 'package:flutter/material.dart';
import 'barbellinventory.dart';
import 'plateinventory.dart';

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
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.ac_unit),
                        title: Text('Aktion 1'),
                        onTap: () {
                          // Führen Sie Aktion 1 aus
                          Navigator.pop(context); // Schließen Sie das PopupMenu
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.access_alarm),
                        title: Text('Aktion 2'),
                        onTap: () {
                          // Führen Sie Aktion 2 aus
                          Navigator.pop(context); // Schließen Sie das PopupMenu
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.add))
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