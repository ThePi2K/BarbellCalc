import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'BarbellCalc Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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

  State<CalculatePlateWeight> createState() => _CalculatePlateWeightState();
}

class _CalculatePlateWeightState extends State<CalculatePlateWeight> {
  late double plateWeight;
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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '(${trainingWeightController.text} - ${barbellWeightController.text}) / 2 = ${plateWeight.toString()}'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  labelText: 'gewünschtes Gewicht',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: barbellWeightController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Hantelgewicht',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
            ],
          ),
          ElevatedButton(onPressed: calculateWeight, child: const Text('CALC'))
        ],
      ),
    );
  }
}
