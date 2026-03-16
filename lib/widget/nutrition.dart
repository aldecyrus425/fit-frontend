import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget NutritionTile(String title, String value, String unit) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        '$title ($unit)',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ],
  );
}