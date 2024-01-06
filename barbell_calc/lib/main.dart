import 'package:flutter/material.dart';
import 'barbell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarbellCalc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CalculatePlateWeight(),
    );
  }
}

class CalculatePlateWeight extends StatefulWidget {
  const CalculatePlateWeight({super.key});

  @override
  State<CalculatePlateWeight> createState() => _CalculatePlateWeightState();
}

class _CalculatePlateWeightState extends State<CalculatePlateWeight> {
  double plateWeight = 0;
  final trainingWeightController = TextEditingController();
  final barbellWeightController = TextEditingController();

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 20),
              Text(
                plateWeight.toString(),
                style: const TextStyle(fontSize: 50.0),
              ),
            ],
          ),
        ),
        const BarbellWidget(distancePlates: 3.0, plateList: [PlateWidget(heightPlate: 170.0), PlateWidget(heightPlate: 150.0), PlateWidget(heightPlate: 70.0)]),
      ],
    );
  }
}


