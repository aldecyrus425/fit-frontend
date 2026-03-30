import 'package:flutter/material.dart';
import 'createUserModel.dart';

class AgeStep extends StatefulWidget {
  final RegisterData data;

  const AgeStep(this.data, {super.key});

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  int selectedAge = 25;

  @override
  void initState() {
    super.initState();
    widget.data.age = selectedAge;
  }

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
              "How Old Are You?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Age in years. This will help us personalize your fitness plan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            // 🔥 Wheel Picker with Highlight
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Wheel
                  ListWheelScrollView.useDelegate(
                    itemExtent: 70,
                    perspective: 0.003,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedAge = index + 1;
                        widget.data.age = selectedAge;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 100,
                      builder: (context, index) {
                        final age = index + 1;
                        final isSelected = age == selectedAge;

                        return Center(
                          child: Text(
                            "$age",
                            style: TextStyle(
                              fontSize: isSelected ? 34 : 20,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Center Highlight Box (like your image)
                  Container(
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}