import 'package:flutter/material.dart';
import 'createUserModel.dart';

class AgeStep  extends StatefulWidget {
  final RegisterData data;
  AgeStep(this.data);

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  int age = 25;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("How Old Are You?", style: TextStyle(fontSize: 24)),

        const SizedBox(height: 20),

        DropdownButton<int>(
          value: age,
          items: List.generate(100, (i) => i + 1)
              .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
              .toList(),
          onChanged: (val) {
            setState(() => age = val!);
            widget.data.age = val;
          },
        ),
      ],
    );
  }
}
