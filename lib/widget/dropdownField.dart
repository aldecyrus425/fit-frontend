import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget dropdownField({
  required String hint,
  required String? value,
  required List<String> options,
  required void Function(String?) onChanged,
  required IconData icon,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white70),
    ),
    child: DropdownButtonFormField<String>(
      value: value,
      dropdownColor: Colors.black87,
      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        border: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      items: options
          .map((e) => DropdownMenuItem<String>(
        value: e,
        child: Text(e),
      ))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $hint' : null,
    ),
  );
}