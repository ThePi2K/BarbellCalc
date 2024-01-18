import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'barbell_widget.dart';
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

  double barbellWeightInclPlates = 0;

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

    if ((olympicBarbells == true) & (standardBarbells == false)) {
      barbellWidth = 'Olympic';
    }

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

  // Function to calculate maxPlates based on the display size
  double calculateMaxPlates() {
    double widthDisplay = MediaQuery.of(context).size.width;
    double startPlates = 39.0;
    double endPlates = 10.0;
    double widthPlate = 32.5;
    double distancePlates = 0.9;
    return ((widthDisplay - (startPlates + endPlates + 10)) /
        (widthPlate + distancePlates));
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

      // set barbellWeightInclPlates the barbellWeight
      barbellWeightInclPlates = barbellWeight;

      // starting calculation

      bool whileFlow = true;

      double plateWeightTemp = plateWeight;

      while (whileFlow) {
        if (plates.isEmpty) {
          break;
        } else {
          double difference = plateWeightTemp - plates.first.weight;
          if (difference >= 0) {
            if (plateListOnBarbell.length + 1 > calculateMaxPlates()) {
              // TOO MANY PLATES ON BARBELL
              break;
            } else {
              plateListOnBarbell
                  .add(PlateWidget(weightPlate: plates.first.weight));
              barbellWeightInclPlates += plates.first.weight * 2;
              plateWeightTemp = difference;
            }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    barbellWeightInclPlates = 0;
    plateListOnBarbell.clear();
  }

  @override
  Widget build(BuildContext context) {
    getBarbells();
    getPlates();
    getMetricSystem();

    bool checkWeightDouble() {
      try {
        double.parse(trainingWeightController.text);
        return true;
      } catch (e) {
        return false;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        autofocus: true,
                        controller: trainingWeightController,
                        inputFormatters: [LengthLimitingTextInputFormatter(6)],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Training Weight',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
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
                        child: const Text('Choose\nBarbell'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          if (!checkWeightDouble()) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const ErrorDialog(
                                    errorMessage: 'Weight is invalid!');
                              },
                            );
                          } else {
                            double worldRecord = metricSystem ? 501 : 1104;
                            if (double.parse(trainingWeightController.text) >
                                worldRecord) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                            'assets/manga_nice_bing_ki.png'),
                                        const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Text(
                                            'That breaks the world record! Congratulations!',
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    // Set contentPadding to zero
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          _launchUrl();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('CHECK DETAILS'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              if (barbellWeight == 0) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const ErrorDialog(
                                        errorMessage:
                                            'You need to choose a Barbell!');
                                  },
                                );
                              } else {
                                if (barbellWeight >
                                    double.parse(
                                        trainingWeightController.text)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const ErrorDialog(
                                          errorMessage:
                                              'You need to choose more weight!');
                                    },
                                  );
                                } else {
                                  calculateWeight();
                                  if (barbellWeightInclPlates !=
                                      double.parse(
                                          trainingWeightController.text)) {
                                    String trainingWeightString =
                                        trainingWeightController.text
                                            .toString();
                                    if (trainingWeightString.endsWith(".0")) {
                                      trainingWeightString =
                                          trainingWeightString.substring(0,
                                              trainingWeightString.length - 2);
                                    }
                                    trainingWeightString +=
                                        ' ${metricSystem ? 'kg' : 'lb'}';

                                    String barbellWeightInclPlatesString =
                                        barbellWeightInclPlates.toString();
                                    if (barbellWeightInclPlatesString
                                        .endsWith(".0")) {
                                      barbellWeightInclPlatesString =
                                          barbellWeightInclPlatesString
                                              .substring(
                                                  0,
                                                  barbellWeightInclPlatesString
                                                          .length -
                                                      2);
                                    }
                                    barbellWeightInclPlatesString +=
                                        ' ${metricSystem ? 'kg' : 'lb'}';

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Attention!'),
                                          content: Text(
                                              'The entered weight ($trainingWeightString) differs from the possible training weight ($barbellWeightInclPlatesString)!'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              }
                            }
                          }
                        },
                        child: const Icon(
                          Icons.calculate,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              BarbellWidget(
                metricSystem: metricSystem,
                plateList: plateListOnBarbell,
                barbellName: barbellName,
                barbellWeight: barbellWeight,
                barbellWidth: barbellWidth,
                barbellWeightInclPlates: barbellWeightInclPlates,
              ),
            ],
          ),
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
      title: const Text('Choose Barbell'),
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
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withOpacity(0.4),
                  borderRadius: BorderRadius.circular(17.0),
                ),
                child: ListTile(
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
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
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
    String weightString = barbell.weight.toString();
    if (weightString.endsWith(".0")) {
      weightString = weightString.substring(0, weightString.length - 2);
    }
    weightString += ' ${metricSystem ? 'kg' : 'lb'}';
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
