import 'package:flutter/material.dart';

class PlateWidget extends StatelessWidget {
  const PlateWidget(
      {super.key, required this.heightPlate, required this.weightPlate});

  final double heightPlate;
  final double weightPlate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightPlate,
      width: 37.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(
          color: Colors.black,
          width: 2.5,
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
  const BarbellWidget(
      {super.key, required this.distancePlates, required this.plateList});

  final double distancePlates;
  final List<PlateWidget> plateList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // bar in the background
          const BarWidget(barPadding: 20.0),
          Row(
            children: [
              const SizedBox(width: 15.0 + 17.0),

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
  const BarWidget({super.key, required this.barPadding});

  final double barPadding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // bar

        Container(
          height: 20.0,
          width: MediaQuery.of(context).size.width - (barPadding * 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: Colors.black,
              width: 1.5,
            ),
          ),
        ),

        Row(
          children: [
            const SizedBox(width: 15.0),
            Container(
              height: 50.0,
              width: 17.0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
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
