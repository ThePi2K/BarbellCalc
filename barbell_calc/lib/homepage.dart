import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
  late String barbellName = '';
  final trainingWeightController = TextEditingController();

  late bool standardBarbells;
  late bool olympicBarbells;
  bool metricSystem = true;

  late List<Plate> allPlates = [];
  late List<Plate> plates = [];
  late List<Barbell> barbells = [];
  late List<Barbell> barbellsOlympic = [];
  late List<Barbell> barbellsStandard = [];

  late List<PlateWidget> plateListOnBarbell = [];

  final Uri _url = Uri.parse(
      'https://edition.cnn.com/2020/05/02/entertainment/hafthor-bjornsson-world-record-trnd/index.html');

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
      allPlates.add(Plate(weight: 20.0, width: 'Olympic'));

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
      barbells.add(
          Barbell(name: 'My first Barbell', weight: 10.0, width: 'Standard'));
      barbells.add(Barbell(
          name: 'My first Olympic Barbell', weight: 20.0, width: 'Olympic'));

      // Encode the updated list to a string
      final String encodedData = Barbell.encode(barbells);

      // Write the updated string to 'barbells_key'
      await prefs.setString('barbells_key', encodedData);
    }

    // add all barbells to their own list
    barbellsOlympic =
        barbells.where((plates) => plates.width == 'Olympic').toList();
    barbellsStandard =
        barbells.where((plates) => plates.width == 'Standard').toList();
  }

  void getMetricSystem() async {
    // connect to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // get bool from SharedPreferences
    metricSystem = prefs.getBool('metricSystem') ?? true;
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
      barbellName = selectedBarbell.name;
    });
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    getPlates();
    getBarbells();
    getMetricSystem();
    return Scaffold(
      // appBar: AppBar(leading: Image.asset('android/app/src/main/res/mipmap/ic_launcher.png'),title: const Text('Barbell Calc')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            controller: trainingWeightController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText:
                                  'Training Weight in ${metricSystem ? 'kg' : 'lb'}',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SelectBarbellDialog(
                                      barbellListOlympic: barbellsOlympic,
                                      metricSystem: metricSystem,
                                      barbellListStandard: barbellsStandard,
                                      setSelectedBarbell: setSelectedBarbell,
                                      standardBarbells: standardBarbells,
                                      olympicBarbells: olympicBarbells,
                                    );
                                  },
                                );
                              },
                              child: const Text('Select Barbell'),
                            ),
                            const SizedBox(width: 10),
                            if (barbellWeight != 0)
                              SizedBox(
                                width: 100,
                                child: Text(
                                  '$barbellName\n(${barbellWeight.toString()} ${metricSystem ? 'kg' : 'lb'})',
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(75, 90),
                    ),
                    onPressed: () {
                      double worldRecord = metricSystem ? 501 : 1104;
                      if (double.parse(trainingWeightController.text) >
                          worldRecord) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Good Job Champ!'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                      'That breaks the world record! Congratulations!'),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Image.asset('assets/arnold-nice.png')
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _launchUrl();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('NICE'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        calculateWeight();
                      }
                    },
                    child: const Icon(
                      Icons.calculate,
                      size: 30.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            BarbellWidget(plateList: plateListOnBarbell),
          ],
        ),
      ),
    );
  }
}

class SelectBarbellDialog extends StatelessWidget {
  const SelectBarbellDialog({
    super.key,
    required this.barbellListStandard,
    required this.barbellListOlympic,
    required this.setSelectedBarbell,
    required this.olympicBarbells,
    required this.standardBarbells,
    required this.metricSystem,
  });

  final bool metricSystem;
  final bool olympicBarbells;
  final bool standardBarbells;
  final List<Barbell> barbellListStandard;
  final List<Barbell> barbellListOlympic;
  final Function(Barbell) setSelectedBarbell;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Barbell'),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (standardBarbells)
                SelectBarbellList(
                  metricSystem: metricSystem,
                  standardBarbells: standardBarbells,
                  olympicBarbells: olympicBarbells,
                  barbellList: barbellListStandard,
                  setSelectedBarbell: setSelectedBarbell,
                ),
              if (olympicBarbells)
                SelectBarbellList(
                  metricSystem: metricSystem,
                  standardBarbells: standardBarbells,
                  olympicBarbells: olympicBarbells,
                  barbellList: barbellListOlympic,
                  setSelectedBarbell: setSelectedBarbell,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectBarbellList extends StatelessWidget {
  const SelectBarbellList({
    super.key,
    required this.barbellList,
    required this.setSelectedBarbell,
    required this.olympicBarbells,
    required this.standardBarbells,
    required this.metricSystem,
  });

  final bool olympicBarbells;
  final bool standardBarbells;
  final bool metricSystem;
  final List<Barbell> barbellList;
  final Function(Barbell) setSelectedBarbell;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < barbellList.length; index++)
          ListTile(
            title: Text(barbellList[index].name),
            subtitle: SelectBarbellListItemSubtitle(
              olympicBarbells: olympicBarbells,
              standardBarbells: standardBarbells,
              metricSystem: metricSystem,
              barbell: barbellList[index],
            ),
            onTap: () {
              Navigator.of(context).pop();
              setSelectedBarbell(barbellList[index]);
            },
          )
      ],
    );
  }
}

class SelectBarbellListItemSubtitle extends StatelessWidget {
  const SelectBarbellListItemSubtitle({
    super.key,
    required this.olympicBarbells,
    required this.standardBarbells,
    required this.metricSystem,
    required this.barbell,
  });

  final bool olympicBarbells;
  final bool standardBarbells;
  final bool metricSystem;
  final Barbell barbell;

  @override
  Widget build(BuildContext context) {
    String weightString = '${barbell.weight} ${metricSystem ? 'kg' : 'lb'}';
    if (olympicBarbells & standardBarbells) {
      return Row(
        children: [
          Text(weightString),
          const SizedBox(
            width: 20,
          ),
          Text(barbell.width),
        ],
      );
    } else {
      return Text(weightString);
    }
  }
}
