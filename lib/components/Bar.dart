import 'package:flutter/material.dart';

class Bar extends StatelessWidget {
  final double amount;
  final double max;
  final String text;
  const Bar(
      {super.key, required this.amount, required this.max, required this.text});

  @override
  Widget build(BuildContext context) {
    final double height = (amount != 0)
        ? (((MediaQuery.of(context).size.height / 3) * .75) * amount) / max
        : 20.0;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
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
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),
                textAlign: TextAlign.center,
                amount.toInt().toString(),
              ),
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.purple[100],
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
