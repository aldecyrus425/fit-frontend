import 'package:flutter/material.dart';
import 'createUserModel.dart';

class LevelStep extends StatelessWidget {
  final RegisterData data;
  LevelStep(this.data);

  final levels = ["Beginner", "Intermediate", "Advanced"];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        hint: const Text("Select Level"),
        value: data.level,
        items: levels
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => data.level = val,
      ),
    );
  }
}
