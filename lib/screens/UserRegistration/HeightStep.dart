import 'package:flutter/material.dart';
import 'createUserModel.dart';

class HeightStep extends StatefulWidget {
  final RegisterData data;

  const HeightStep(this.data, {super.key});

  @override
  State<HeightStep> createState() => _HeightStepState();
}

class _HeightStepState extends State<HeightStep> {
  double height = 170;

  @override
  void initState() {
    super.initState();
    widget.data.height = height;
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
              "Your Height",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Enter your height in centimeters. This helps us personalize your plan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            // Height Display Card (same as weight style)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.deepPurple,
                  width: 2,
                ),
              ),
              child: Text(
                "${height.toStringAsFixed(1)} cm",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Slider Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.deepPurple,
                      inactiveTrackColor:
                      Colors.deepPurple.withOpacity(0.2),
                      thumbColor: Colors.deepPurple,
                      overlayColor:
                      Colors.deepPurple.withOpacity(0.2),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                    ),
                    child: Slider(
                      min: 100,
                      max: 220,
                      divisions: 120,
                      value: height,
                      label: "${height.toStringAsFixed(1)} cm",
                      onChanged: (val) {
                        setState(() {
                          height = val;
                          widget.data.height = val;
                        });
                      },
                    ),
                  ),

                  // Min / Max labels
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("100 cm",
                          style: TextStyle(color: Colors.grey)),
                      Text("220 cm",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}