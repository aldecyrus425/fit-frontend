import 'package:flutter/material.dart';
import 'createUserModel.dart';
import 'AccountStep.dart';
import 'AgeStep.dart';
import 'HeightStep.dart';
import 'LevelStep.dart';
import 'ServiceStep.dart';
import 'SummaryStep.dart';
import 'WeightStep.dart';

class RegistrationUser extends StatefulWidget {
  const RegistrationUser({super.key});

  @override
  State<RegistrationUser> createState() => _RegistrationUserState();
}

class _RegistrationUserState extends State<RegistrationUser> {
  final PageController _controller = PageController();
  final RegisterData data = RegisterData();

  int currentPage = 0;

  void next() {
    if (currentPage < 6) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      submit();
    }
  }

  void back() {
    if (currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void submit() {
    // TODO: connect your API here
    print("FINAL DATA:");
    print(data.name);
    print(data.email);
    print(data.password);
    print(data.service);
    print(data.level);
    print(data.age);
    print(data.weight);
    print(data.height);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => currentPage = i),
        children: [
          AccountStep(data),
          ServiceStep(data),
          LevelStep(data),
          AgeStep(data),
          WeightStep(data),
          HeightStep(data),
          SummaryStep(data),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (currentPage > 0)
              ElevatedButton(onPressed: back, child: const Text("Back")),

            ElevatedButton(
              onPressed: next,
              child: Text(currentPage == 6 ? "Finish" : "Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
