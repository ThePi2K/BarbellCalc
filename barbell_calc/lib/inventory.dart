import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Inventory(title: 'Barbells', image: 'assets/barbell_bing.jpeg'),
            SizedBox(height: 15),
            Inventory(title: 'Plates', image: 'assets/plates_bing.jpeg'),
          ],
        ),
      ),
    );
  }
}

class Inventory extends StatelessWidget {
  const Inventory({super.key, required this.title, required this.image});

  final String title;
  final String image;

  final double textSize = 60.0;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
              // adding BlendMode to picture
              Colors.white.withOpacity(0.5),
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
    );
  }
}