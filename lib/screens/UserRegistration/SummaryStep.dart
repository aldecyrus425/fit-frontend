import 'package:flutter/material.dart';
import 'createUserModel.dart';

class SummaryStep extends StatelessWidget {
  final RegisterData data;

  const SummaryStep(this.data, {super.key});

  Widget buildItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Title
              const Text(
                "Your Summary",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Please review your information before continuing.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Data Cards
              Expanded(
                child: ListView(
                  children: [
                    buildItem(Icons.person, "Name", data.name ?? ""),
                    buildItem(Icons.email, "Email", data.email ?? ""),
                    buildItem(Icons.fitness_center, "Service", data.service ?? ""),
                    buildItem(Icons.bar_chart, "Level", data.level ?? ""),
                    buildItem(Icons.cake, "Age", "${data.age} years"),
                    buildItem(Icons.monitor_weight, "Weight",
                        "${data.weight?.toStringAsFixed(1)} kg"),
                    buildItem(Icons.height, "Height",
                        "${data.height?.toStringAsFixed(1)} cm"),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}