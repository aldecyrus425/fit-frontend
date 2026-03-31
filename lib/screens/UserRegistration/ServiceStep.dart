import 'package:fit_final/models/serviceOptions.dart';
import 'package:flutter/material.dart';
import 'createUserModel.dart';

class ServiceStep extends StatefulWidget {
  final RegisterData data;

  const ServiceStep(this.data, {super.key});

  @override
  State<ServiceStep> createState() => _ServiceStepState();
}

class _ServiceStepState extends State<ServiceStep> {

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    widget.data.service = serviceOptions[0];
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
              "Select Your Service",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Choose a service that fits your fitness goals.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            // Wheel Picker
            Expanded(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 70,
                perspective: 0.003,
                diameterRatio: 1.5,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                    widget.data.service = serviceOptions[index];
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: serviceOptions.length,
                  builder: (context, index) {
                    final isSelected = index == selectedIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.deepPurple, width: 2)
                            : null,
                      ),
                      child: Text(
                        serviceOptions[index],
                        style: TextStyle(
                          fontSize: isSelected ? 24 : 18,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.grey,
                        ),
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