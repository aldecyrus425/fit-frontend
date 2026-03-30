import 'package:flutter/material.dart';
import 'createUserModel.dart';

class SummaryStep extends StatelessWidget {
  final RegisterData data;
  SummaryStep(this.data);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${data.name}"),
          Text("Email: ${data.email}"),
          Text("Service: ${data.service}"),
          Text("Level: ${data.level}"),
          Text("Age: ${data.age}"),
          Text("Weight: ${data.weight}"),
          Text("Height: ${data.height}"),
        ],
      ),
    );
  }
}