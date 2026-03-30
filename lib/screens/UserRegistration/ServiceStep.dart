import 'package:flutter/material.dart';
import 'createUserModel.dart';

class ServiceStep extends StatelessWidget {
  final RegisterData data;
  ServiceStep(this.data);

  final services = ["Gym", "Yoga", "Cardio"];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        hint: const Text("Select Service"),
        value: data.service,
        items: services
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) => data.service = val,
      ),
    );
  }
}
