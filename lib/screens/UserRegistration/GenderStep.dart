import 'package:flutter/material.dart';
import 'createUserModel.dart';

class GenderStep extends StatefulWidget {
  final RegisterData data;

  const GenderStep(this.data, {super.key});

  @override
  State<GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends State<GenderStep> {
  final List<Map<String, dynamic>> genders = [
    {
      "label": "Male",
      "icon": Icons.male,
      "color": Colors.blue,
    },
    {
      "label": "Female",
      "icon": Icons.female,
      "color": Colors.pink,
    },
    {
      "label": "Other",
      "icon": Icons.transgender,
      "color": Colors.purple,
    },
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // default value
    widget.data.gender = genders[0]["label"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// 🔹 Title
            const Text(
              "Your Gender",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Select your gender for a more personalized experience.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            /// 🔥 Wheel Picker (Same Style)
            Expanded(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 80,
                perspective: 0.003,
                diameterRatio: 1.5,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                    widget.data.gender = genders[index]["label"];
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: genders.length,
                  builder: (context, index) {
                    final isSelected = index == selectedIndex;
                    final item = genders[index];

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
                            color: isSelected
                                ? item["color"]
                                : Colors.grey,
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