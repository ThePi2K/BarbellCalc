import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'barbellwidget.dart';
import 'barbell.dart';
import 'plate.dart';
import 'inventory.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double plateWeight = 0;
  final trainingWeightController = TextEditingController();
  final barbellWeightController = TextEditingController();
  bool calculated = false;

  late List<Plate> plates = [];
  late List<Barbell> barbells = [];

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
  }

  void calculateWeight() {
    setState(() {
      // close keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      // reformatting text inputs (remove spaces and minus, replace , with .)
      void reformatTextInput(TextEditingController controller) {
        controller.text = controller.text
            .replaceAll(" ", "")
            .replaceAll("-", "")
            .replaceAll(",", ".");
      }

      reformatTextInput(trainingWeightController);
      reformatTextInput(barbellWeightController);

      // calculate the weight for the plates
      plateWeight = (double.parse(trainingWeightController.text) -
              double.parse(barbellWeightController.text)) /
          2;

      // set calculated true
      calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    getBarbells();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      TextField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        controller: trainingWeightController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Training Weight',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        controller: barbellWeightController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Barbell Weight',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  // ElevatedButton(
                  //     onPressed: calculateWeight, child: const Text('CALC')),
                  // const SizedBox(height: 10),
                  Visibility(
                    visible: calculated,
                    child: Text(
                      plateWeight.toString(),
                      style: const TextStyle(fontSize: 40.0),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: calculated,
              child: const BarbellWidget(
                plateList: [
                  PlateWidget(weightPlate: 25),
                  PlateWidget(weightPlate: 20),
                  PlateWidget(weightPlate: 15),
                  PlateWidget(weightPlate: 10),
                  PlateWidget(weightPlate: 5),
                  PlateWidget(weightPlate: 2.5),
                  PlateWidget(weightPlate: 1.25),
                  PlateWidget(weightPlate: 1),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: calculateWeight,
        child: const Icon(Icons.calculate_rounded),
      ),
    );
  }
}