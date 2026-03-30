import 'package:flutter/material.dart';
import 'createUserModel.dart';

class LevelStep extends StatefulWidget {
  final RegisterData data;

  const LevelStep(this.data, {super.key});

  @override
  State<LevelStep> createState() => _LevelStepState();
}

class _LevelStepState extends State<LevelStep> {
  final List<Map<String, dynamic>> levels = [
    {"label": "Beginner", "icon": Icons.eco, "color": Colors.green},
    {"label": "Intermediate", "icon": Icons.fitness_center, "color": Colors.orange},
    {"label": "Advanced", "icon": Icons.local_fire_department, "color": Colors.red},
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Title
            const Text(
              "Your Fitness Level",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Select your current fitness experience level.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            // Wheel Picker
            Expanded(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 80,
                perspective: 0.003,
                diameterRatio: 1.5,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                    widget.data.level = levels[index]["label"];
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: levels.length,
                  builder: (context, index) {
                    final isSelected = index == selectedIndex;
                    final item = levels[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item["color"].withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(color: item["color"], width: 2)
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item["icon"],
                            color: isSelected ? item["color"] : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item["label"],
                            style: TextStyle(
                              fontSize: isSelected ? 22 : 18,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? item["color"]
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}