import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Placeholder(),
      ),
    );
  }
}
