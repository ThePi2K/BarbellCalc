import 'package:flutter/material.dart';

class PlateWidget extends StatelessWidget {
  const PlateWidget({super.key, required this.weightPlate});

  final double weightPlate;

  @override
  Widget build(BuildContext context) {
    // calculate height
    double heightPlate = 0;

    if (weightPlate >= 25) {
      heightPlate = 200.0;
    } else if (weightPlate >= 20) {
      heightPlate = 170.0;
    } else if (weightPlate >= 15) {
      heightPlate = 150.0;
    } else if (weightPlate >= 10) {
      heightPlate = 130.0;
    } else if (weightPlate >= 5) {
      heightPlate = 100.0;
    } else if (weightPlate >= 2.5) {
      heightPlate = 80.0;
    } else if (weightPlate >= 1) {
      heightPlate = 60.0;
    } else {
      heightPlate = 45.0;
    }

    return Container(
      height: heightPlate,
      width: 32.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(weightPlate.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.background),
            textAlign: TextAlign.center),
      ),
    );
  }
}

class BarbellWidget extends StatelessWidget {
  const BarbellWidget({super.key, required this.plateList});

  final double distancePlates = 0.9;
  final List<PlateWidget> plateList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // bar in the background
          const BarWidget(),
          Row(
            children: [
              const SizedBox(width: 10.0 + 17.0),

              // here are the plates from the array plateList
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
        ],
      ),
    );
  }
}

class BarWidget extends StatelessWidget {
  const BarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // bar
        Expanded(
          child: Container(
            height: 20.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Theme.of(context).colorScheme.inversePrimary.withOpacity(0.0),
                  Theme.of(context).colorScheme.inversePrimary.withOpacity(1.0),
                ],
                stops: const [0.0, 0.017],
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
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
                right: BorderSide(
                  color: Colors.black.withOpacity(1.0),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 10.0),
            Container(
              height: 50.0,
              width: 17.0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
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
