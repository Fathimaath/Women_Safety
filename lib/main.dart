import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'community_forum_screen.dart';
import 'self_defense_tips_screen.dart';
import 'trusted_contacts_screen.dart';
import 'auth_page.dart';
import 'live_tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(); // ✅ Firebase initialization
  } catch (e) {
    print("Firebase init error: $e");
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isRegistered = prefs.getString('email') != null;

  runApp(SheSafeApp(isRegistered: isRegistered));
}

class SheSafeApp extends StatelessWidget {
  final bool isRegistered;
  const SheSafeApp({super.key, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'She Safe',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: isRegistered ? const HomePage() : const AuthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const List<String> safetyTips = [
    "Always share your location with a trusted contact.",
    "Use emergency SOS when in danger.",
    "Be aware of your surroundings, especially at night.",
    "Avoid sharing personal details with strangers online.",
    "Use well-lit and busy routes when traveling alone.",
  ];

  void _playSiren() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('siren.mp3'));
    } catch (e) {
      print("Error playing siren: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("She Safe - Women Safety App"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.pink.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Stay Safe, Stay Connected",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Your safety is our priority. Use the features below to ensure help is just a tap away!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  height: 160,
                  enlargeCenterPage: true,
                ),
                items:
                    safetyTips.map((tip) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        color: Colors.pink.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Center(
                            child: Text(
                              tip,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildFeatureCard(
                      context,
                      Icons.sos,
                      "Emergency Alert",
                      _playSiren,
                    ),
                    _buildFeatureCard(context, Icons.map, "Live Tracking"),
                    _buildFeatureCard(
                      context,
                      Icons.contacts,
                      "Trusted Contacts",
                    ),
                    _buildFeatureCard(context, Icons.group, "Community Forum"),
                    _buildFeatureCard(
                      context,
                      Icons.shield,
                      "Self-Defense Tips",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String label, [
    VoidCallback? onTap,
  ]) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ?? () => _navigateToFeature(context, label),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.pinkAccent),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFeature(BuildContext context, String label) {
    switch (label) {
      case "Live Tracking":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LiveTrackingScreen()),
        );
        break;
      case "Community Forum":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CommunityForumScreen()),
        );
        break;
      case "Self-Defense Tips":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SelfDefenseTipsScreen(),
          ),
        );
        break;
      case "Trusted Contacts":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TrustedContactsScreen(),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Feature coming soon!")));
    }
  }
}
