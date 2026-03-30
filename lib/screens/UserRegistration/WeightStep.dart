import 'package:flutter/material.dart';
import 'createUserModel.dart';

class WeightStep extends StatefulWidget {
  final RegisterData data;

  const WeightStep(this.data, {super.key});

  @override
  State<WeightStep> createState() => _WeightStepState();
}

class _WeightStepState extends State<WeightStep> {
  double weight = 60;

  @override
  void initState() {
    super.initState();
    widget.data.weight = weight;
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
              "Your Weight",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Enter your weight in kilograms. This helps us tailor your fitness plan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            // Weight Display Card
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
                "${weight.toStringAsFixed(1)} kg",
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
                      inactiveTrackColor: Colors.deepPurple.withOpacity(0.2),
                      thumbColor: Colors.deepPurple,
                      overlayColor: Colors.deepPurple.withOpacity(0.2),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                    ),
                    child: Slider(
                      min: 30,
                      max: 150,
                      divisions: 120,
                      value: weight,
                      label: "${weight.toStringAsFixed(1)} kg",
                      onChanged: (val) {
                        setState(() {
                          weight = val;
                          widget.data.weight = val;
                        });
                      },
                    ),
                  ),

                  // Min / Max labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("30 kg", style: TextStyle(color: Colors.grey)),
                      Text("150 kg", style: TextStyle(color: Colors.grey)),
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