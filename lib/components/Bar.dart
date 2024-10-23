import 'package:flutter/material.dart';

class Bar extends StatelessWidget {
  final double amount;
  final max;
  final String text;
  const Bar(
      {super.key, required this.amount, required this.max, required this.text});

  @override
  Widget build(BuildContext context) {
    final height =
        (((MediaQuery.of(context).size.height / 3) * .75) * amount) / max;


    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.purple[100],
        ),
        margin: const EdgeInsets.fromLTRB(7.0, 9.5, 7.0, 1.0),
        padding: const EdgeInsets.only(bottom: 2.0),
        height: height,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            text,
          ),
        ),
      ),
    );
  }
}
