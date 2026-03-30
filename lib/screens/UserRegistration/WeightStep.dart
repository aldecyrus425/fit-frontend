import 'package:flutter/material.dart';
import 'createUserModel.dart';

class WeightStep extends StatefulWidget {
  final RegisterData data;
  WeightStep(this.data);

  @override
  State<WeightStep> createState() => _WeightStepState();
}

class _WeightStepState extends State<WeightStep> {
  double weight = 60;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Your Weight (kg)"),
        Slider(
          min: 30,
          max: 150,
          value: weight,
          onChanged: (val) {
            setState(() => weight = val);
            widget.data.weight = val;
          },
        ),
        Text("${weight.toStringAsFixed(1)} kg"),
      ],
    );
  }
}