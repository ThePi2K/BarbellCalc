import 'package:flutter/material.dart';

class PlateWidget extends StatelessWidget {
  const PlateWidget({super.key, required this.heightPlate});

  final double heightPlate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightPlate,
      width: 10.0,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
    );
  }
}

class BarbellWidget extends StatelessWidget {
  const BarbellWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // bar in the background
          BarWidget(barPadding: 20.0, barColor: Colors.grey),
          Row(
            children: [
              SizedBox(width: 20.0),
              // plates start
              SizedBox(width: 2),
              PlateWidget(heightPlate: 150.0),
              SizedBox(width: 2),
              PlateWidget(heightPlate: 100.0),
              SizedBox(width: 2),
              PlateWidget(heightPlate: 100.0),
              SizedBox(width: 2),
              PlateWidget(heightPlate: 50.0),
            ],
          ),
        ],
      ),
    );
  }
}

class BarWidget extends StatelessWidget {
  const BarWidget(
      {super.key, required this.barPadding, required this.barColor});

  final double barPadding;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: 10.0,
          width: MediaQuery.of(context).size.width - (barPadding * 2),
          decoration: BoxDecoration(
            color: barColor,
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 10.0),
            Container(
              height: 18.0,
              width: 10.0,
              decoration: BoxDecoration(
                color: barColor,
              ),
            )
          ],
        )
      ],
    );
  }
}
