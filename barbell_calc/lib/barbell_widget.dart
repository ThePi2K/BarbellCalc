import 'package:flutter/material.dart';

class PlateWidget extends StatelessWidget {
  const PlateWidget({super.key, required this.weightPlate});

  final double weightPlate;

  @override
  Widget build(BuildContext context) {
    // calculate height
    double heightPlate = 0;

    if (weightPlate >= 25) {
      heightPlate = 250.0;
    } else if (weightPlate >= 20) {
      heightPlate = 200.0;
    } else if (weightPlate >= 15) {
      heightPlate = 170.0;
    } else if (weightPlate >= 10) {
      heightPlate = 150.0;
    } else if (weightPlate >= 5) {
      heightPlate = 130.0;
    } else if (weightPlate >= 2.5) {
      heightPlate = 100.0;
    } else if (weightPlate >= 1) {
      heightPlate = 80.0;
    } else {
      heightPlate = 60.0;
    }

    String plateWeightString = weightPlate.toString();
    if (plateWeightString.endsWith(".0")) {
      plateWeightString =
          plateWeightString.substring(0, plateWeightString.length - 2);
    }

    double fontSize = 15;
    if (plateWeightString.length > 3) {
      fontSize = 11;
    }

    return Container(
      height: heightPlate,
      width: 32.5,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(1.0),
        // color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(plateWeightString,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              height: 1.2,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center),
      ),
    );
  }
}

class BarbellWidget extends StatelessWidget {
  const BarbellWidget({
    super.key,
    required this.plateList,
    required this.barbellName,
    required this.barbellWeight,
    required this.barbellWidth,
    required this.barbellWeightInclPlates,
    required this.metricSystem,
    required this.weightOnBarbellTitle,
  });

  final double distancePlates = 0.9;
  final List<PlateWidget> plateList;
  final String barbellName;
  final double barbellWeight;
  final double barbellWeightInclPlates;
  final String barbellWidth;
  final bool metricSystem;
  final String weightOnBarbellTitle;

  @override
  Widget build(BuildContext context) {
    String barbellWeightString = barbellWeight.toString();
    if (barbellWeightString.endsWith(".0")) {
      barbellWeightString =
          barbellWeightString.substring(0, barbellWeightString.length - 2);
    }
    barbellWeightString += ' ${metricSystem ? 'kg' : 'lb'}';

    String barbellWeightInclPlatesString = barbellWeightInclPlates.toString();
    if (barbellWeightInclPlatesString.endsWith(".0")) {
      barbellWeightInclPlatesString = barbellWeightInclPlatesString.substring(
          0, barbellWeightInclPlatesString.length - 2);
    }
    barbellWeightInclPlatesString += ' ${metricSystem ? 'kg' : 'lb'}';

    return Column(
      children: [
        (barbellWeight != 0)
            ? Text('$barbellName ($barbellWeightString)',
                style: const TextStyle(fontSize: 16))
            : const Text('', style: TextStyle(fontSize: 16)),
        (barbellWeightInclPlates != 0)
            ? Text('$weightOnBarbellTitle: $barbellWeightInclPlatesString')
            : const Text(' '),
        SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
              child: Stack(alignment: Alignment.centerLeft, children: [
                BarWidget(barbellWidth: barbellWidth),
                Row(
                  children: [
                    const SizedBox(width: 15.0 + 23.0),
                    Row(
                      children: plateList.map((widget) {
                        return Row(
                          children: [
                            SizedBox(width: distancePlates),
                            widget,
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ]),
            )),
      ],
    );
  }
}

class BarWidget extends StatelessWidget {
  const BarWidget({super.key, required this.barbellWidth});

  final String barbellWidth;

  @override
  Widget build(BuildContext context) {
    double heightStandard = 20.0;
    double heightOlympic = 35.0;
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // bar
        Row(
          children: [
            Container(
              width: 15,
              height: heightStandard,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .inversePrimary
                        .withOpacity(0.0),
                    Theme.of(context)
                        .colorScheme
                        .inversePrimary
                        .withOpacity(0.4),
                  ],
                  stops: const [0.0, 5],
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.black.withOpacity(1.0),
                    width: 1.5,
                  ),
                  bottom: BorderSide(
                    color: Colors.black.withOpacity(1.0),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 23),
            Expanded(
              child: Container(
                height: (barbellWidth == 'Standard')
                    ? heightStandard
                    : heightOlympic,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withOpacity(0.4),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0),
                  ),
                  border: const Border(
                    top: BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                    right: BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        // stopper
        Row(
          children: [
            const SizedBox(width: 15.0),
            Container(
              height: 60.0,
              width: 23.0,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary
                    .withOpacity(0.4),
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
