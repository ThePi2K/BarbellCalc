import 'package:flutter/material.dart';
import 'barbell.dart';

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
                        controller: trainingWeightController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Training Weight',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      TextField(
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
                  ElevatedButton(
                      onPressed: calculateWeight, child: const Text('CALC')),
                  const SizedBox(height: 10),
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
                  PlateWidget(weightPlate: 30),
                  PlateWidget(weightPlate: 25),
                  PlateWidget(weightPlate: 2.5),
                  PlateWidget(weightPlate: 2.5),
                  PlateWidget(weightPlate: 2.5),
                  PlateWidget(weightPlate: 2.5),
                  PlateWidget(weightPlate: 1.25),
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
