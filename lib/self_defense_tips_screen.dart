import 'package:flutter/material.dart';

class SelfDefenseTipsScreen extends StatelessWidget {
  const SelfDefenseTipsScreen({super.key});

  final List<String> selfDefenseTips = const [
    "1. Stay aware of your surroundings and trust your instincts.",
    "2. Keep your phone charged and easily accessible.",
    "3. Walk confidently and maintain eye contact with strangers.",
    "4. Carry a personal safety alarm or pepper spray if legal.",
    "5. Learn basic self-defense moves like palm strikes and knee kicks.",
    "6. In dangerous situations, make noise to attract attention.",
    "7. Always have a plan and know your escape routes.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Self-Defense Tips"),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.pink.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: selfDefenseTips.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.pink.shade100,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: const Icon(
                  Icons.shield,
                  color: Colors.white,
                  size: 30,
                ),
                title: Text(
                  selfDefenseTips[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
