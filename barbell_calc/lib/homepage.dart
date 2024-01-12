import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'barbell-widget.dart';
import 'barbell.dart';
import 'plate.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double plateWeight = 0;
  double barbellWeight = 0;
  String barbellWidth = 'Standard';
  final trainingWeightController = TextEditingController();

  late bool standardBarbells;
  late bool olympicBarbells;

  late List<Plate> allPlates = [];
  late List<Plate> plates = [];
  late List<Barbell> barbells = [];

  late List<PlateWidget> plateListOnBarbell = [];

  void getPlates() async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get plates from SharedPreferences
    final String? platesString = prefs.getString('plates_key');

    // check if Items in List
    if (platesString != null) {
      setState(() {
        // save the plates into the List "plates"
        allPlates = Plate.decode(platesString);
      });
    }

    // if 0 plates
    if (allPlates.isEmpty) {
      // Create a new Plate and add it to the list
      allPlates.add(Plate(weight: 20.0, width: 'Standard'));

      // Encode the updated list to a string
      final String encodedData = Plate.encode(allPlates);

      // Write the updated string to 'plates_key'
      await prefs.setString('plates_key', encodedData);
    }

    // add all available plates from allPlates (all from this width) to plates
    plates = allPlates.where((plate) => plate.width == barbellWidth).toList();
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

    // get available widths
    standardBarbells = prefs.getBool('standardBarbells') ?? true;
    olympicBarbells = prefs.getBool('olympicBarbells') ?? false;

    // if 0 barbells
    if (barbells.isEmpty) {
      // Create a new Barbell and add it to the list
      if (standardBarbells) {
        barbells.add(
            Barbell(name: 'My first Barbell', weight: 10.0, width: 'Standard'));
      }
      if (olympicBarbells) {
        barbells.add(Barbell(
            name: 'My first Olympic Barbell', weight: 20.0, width: 'Olympic'));
      }

      // Encode the updated list to a string
      final String encodedData = Barbell.encode(barbells);

      // Write the updated string to 'barbells_key'
      await prefs.setString('barbells_key', encodedData);
    }

    // remove barbells with unchecked width
    if (standardBarbells == false) {
      barbells =
          barbells.where((barbells) => barbells.width == 'Olympic').toList();
    } else if (olympicBarbells == false) {
      barbells =
          barbells.where((barbells) => barbells.width == 'Standard').toList();
    }
  }

  void calculateWeight() {
    setState(() {
      // clear plates on barbell
      plateListOnBarbell = [];

      // get plates
      getPlates();

      // close keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      // reformatting text input (remove spaces and minus, replace , with .)
      trainingWeightController.text = trainingWeightController.text
          .replaceAll(" ", "")
          .replaceAll("-", "")
          .replaceAll(",", ".");

      // calculate the weight for the plates
      plateWeight =
          (double.parse(trainingWeightController.text) - barbellWeight) / 2;

      // starting calculation

      bool whileFlow = true;

      double plateWeightTemp = plateWeight;

      while (whileFlow) {
        if (plates.isEmpty) {
          break;
        } else {
          double difference = plateWeightTemp - plates.first.weight;
          if (difference >= 0) {
            plateListOnBarbell
                .add(PlateWidget(weightPlate: plates.first.weight));
            plateWeightTemp = difference;
          } else if (difference < 0) {
            plates.remove(plates.first);
          }
        }
      }
    });
  }

  void setSelectedBarbell(Barbell selectedBarbell) {
    setState(() {
      barbellWeight = selectedBarbell.weight;
      barbellWidth = selectedBarbell.width;
    });
    calculateWeight();
  }

  @override
  Widget build(BuildContext context) {
    getPlates();
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
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SelectBarbellDialog(
                                barbellList: barbells,
                                setSelectedBarbell: setSelectedBarbell,
                                standardBarbells: standardBarbells,
                                olympicBarbells: olympicBarbells,
                              );
                            },
                          );
                        },
                        child: const Text('Select Barbell'),
                      )
                    ],
                  ),
                  Text(
                    plateWeight.toString(),
                    style: const TextStyle(fontSize: 40.0),
                  ),
                ],
              ),
            ),
            BarbellWidget(
              plateList: plateListOnBarbell,
            ),
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

class SelectBarbellDialog extends StatelessWidget {
  const SelectBarbellDialog({
    super.key,
    required this.barbellList,
    required this.setSelectedBarbell,
    required this.olympicBarbells,
    required this.standardBarbells,
  });

  final bool olympicBarbells;
  final bool standardBarbells;
  final List<Barbell> barbellList;
  final Function(Barbell) setSelectedBarbell;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Barbell'),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: barbellList.length,
          itemBuilder: (BuildContext context, int index) {
            return SelectBarbellListItem(
              barbell: barbellList[index],
              index: index,
              barbellListLength: barbellList.length,
              setSelectedBarbell: setSelectedBarbell,
              olympicBarbells: olympicBarbells,
              standardBarbells: standardBarbells,
            );
          },
        ),
      ),
    );
  }
}

class SelectBarbellListItem extends StatelessWidget {
  const SelectBarbellListItem({
    super.key,
    required this.barbell,
    required this.index,
    required this.olympicBarbells,
    required this.standardBarbells,
    required this.barbellListLength,
    required this.setSelectedBarbell,
  });

  final bool olympicBarbells;
  final bool standardBarbells;
  final Barbell barbell;
  final int index;
  final int barbellListLength;
  final Function(Barbell) setSelectedBarbell;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(barbell.name),
        subtitle: SelectBarbellListItemSubtitle(
          olympicBarbells: olympicBarbells,
          standardBarbells: standardBarbells,
          barbell: barbell,
        ),
        onTap: () {
          Navigator.of(context).pop();
          setSelectedBarbell(barbell);
        },
      ),
    );
  }
}

class SelectBarbellListItemSubtitle extends StatelessWidget {
  const SelectBarbellListItemSubtitle({
    super.key,
    required this.olympicBarbells,
    required this.standardBarbells,
    required this.barbell,
  });

  final bool olympicBarbells;
  final bool standardBarbells;
  final Barbell barbell;

  @override
  Widget build(BuildContext context) {
    if (olympicBarbells & standardBarbells) {
      return Row(
        children: [
          Text(barbell.weight.toString()),
          const SizedBox(
            width: 20,
          ),
          Text(barbell.width),
        ],
      );
    } else {
      return Text(barbell.weight.toString());
    }
  }
}
