import 'package:flutter/material.dart';
import 'createUserModel.dart';

class AccountStep extends StatelessWidget {
  final RegisterData data;
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  AccountStep(this.data);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Create Account", style: TextStyle(fontSize: 24)),

          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Name"),
            onChanged: (v) => data.name = v,
          ),

          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: "Email"),
            onChanged: (v) => data.email = v,
          ),

          TextField(
            controller: passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
            onChanged: (v) => data.password = v,
          ),
        ],
      ),
    );
  }
}
