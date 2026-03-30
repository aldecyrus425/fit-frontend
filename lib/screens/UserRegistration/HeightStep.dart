import 'package:flutter/material.dart';
import 'createUserModel.dart';

class HeightStep extends StatefulWidget {
  final RegisterData data;
  HeightStep(this.data);

  @override
  State<HeightStep> createState() => _HeightStepState();
}

class _HeightStepState extends State<HeightStep> {
  double height = 170;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Your Height (cm)"),
        Slider(
          min: 100,
          max: 220,
          value: height,
          onChanged: (val) {
            setState(() => height = val);
            widget.data.height = val;
          },
        ),
        Text("${height.toStringAsFixed(1)} cm"),
      ],
    );
  }
}