import 'package:flutter/material.dart';

class SelfDefenseTipsScreen extends StatefulWidget {
  const SelfDefenseTipsScreen({super.key});

  @override
  _SelfDefenseTipsScreenState createState() => _SelfDefenseTipsScreenState();
}

class _SelfDefenseTipsScreenState extends State<SelfDefenseTipsScreen> {
  final List<String> selfDefenseTips = const [
    "1. Stay aware of your surroundings and trust your instincts.",
    "2. Keep your phone charged and easily accessible.",
    "3. Walk confidently and maintain eye contact with strangers.",
    "4. Carry a personal safety alarm or pepper spray if legal.",
    "5. Learn basic self-defense moves like palm strikes and knee kicks.",
    "6. In dangerous situations, make noise to attract attention.",
    "7. Always have a plan and know your escape routes.",
  ];

  List<String> displayedTips = [];

  @override
  void initState() {
    super.initState();
    displayedTips = List.from(selfDefenseTips);
  }

  void _filterTips(String query) {
    setState(() {
      displayedTips =
          selfDefenseTips
              .where((tip) => tip.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: _filterTips,
                decoration: InputDecoration(
                  labelText: "Search Tips",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayedTips.length,
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
                        displayedTips[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Add action like showing a more detailed page
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
