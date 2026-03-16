import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget InputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool obscure = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    ),
  );
}