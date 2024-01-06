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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
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
  int currentPageIndex = 0;

  final List<Widget> pages = [
    const MainPage(),
    const InventoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.primary,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.inventory)),
            label: 'Inventory',
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
    );
  }
}

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
    return Column(
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
        // Barbell
        Visibility(
          visible: calculated,
          child: BarbellWidget(
            colorBar: Theme.of(context).colorScheme.secondary,
            distancePlates: 3.0,
            plateList: [
              PlateWidget(
                  heightPlate: 170.0,
                  colorPlates: Theme.of(context).colorScheme.primary),
              PlateWidget(
                  heightPlate: 150.0,
                  colorPlates: Theme.of(context).colorScheme.primary),
              PlateWidget(
                  heightPlate: 70.0,
                  colorPlates: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ],
    );
  }
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_sharp),
              title: Text('Notification 1'),
              subtitle: Text('This is a notification'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_sharp),
              title: Text('Notification 2'),
              subtitle: Text('This is a notification'),
            ),
          ),
        ],
      ),
    );
  }
}
