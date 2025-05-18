import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  _CommunityForumScreenState createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  final TextEditingController postController = TextEditingController();
  String selectedPostType = 'Tip';
  bool hasJoinedCommunity = false;

  final List<String> postTypes = ['Tip', 'Danger Alert', 'Event'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadJoinStatus();
  }

  Future<void> loadJoinStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasJoinedCommunity = prefs.getBool('joinedCommunity') ?? false;
    });
  }

  Future<void> joinCommunity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('joinedCommunity', true);
    setState(() {
      hasJoinedCommunity = true;
    });
  }

  Future<void> addPost() async {
    if (postController.text.isNotEmpty) {
      Position? position;

      String? mapUrl;
      GeoPoint? geoPoint;

      if (selectedPostType == 'Danger Alert') {
        position = await _getCurrentPosition();
        if (position != null) {
          mapUrl =
              "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
          geoPoint = GeoPoint(position.latitude, position.longitude);
        }
      }

      await _firestore.collection('community_posts').add({
        'type': selectedPostType,
        'text': postController.text.trim(),
        'location': geoPoint,
        'map_url': mapUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      postController.clear();
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<void> _openMap(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open map.")));
    }
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Forum"),
        backgroundColor: Colors.pink,
      ),
      body: hasJoinedCommunity ? _buildForumUI() : _buildJoinPrompt(),
    );
  }

  Widget _buildJoinPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Join the Her Safe Community to access safety alerts, tips, and discussions.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: joinCommunity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Join Community",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumUI() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.pink.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Share and Connect with the Community",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('community_posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final mapUrl = post['map_url'];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _getPostTypeLabel(post['type']),
                            const SizedBox(height: 4),
                            Text(
                              post['text'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (post['type'] == 'Danger Alert' &&
                                mapUrl != null &&
                                mapUrl.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () => _openMap(mapUrl),
                                  icon: const Icon(
                                    Icons.map,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "📍 View on Map",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.pinkAccent, // Updated color
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DropdownButton<String>(
                value: selectedPostType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPostType = value;
                    });
                  }
                },
                items:
                    postTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: postController,
                  decoration: InputDecoration(
                    hintText: "Share something...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: addPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getPostTypeLabel(String type) {
    Color labelColor;
    String labelText;

    switch (type) {
      case 'Danger Alert':
        labelColor = Colors.red;
        labelText = "⚠️ Danger Alert";
        break;
      case 'Event':
        labelColor = Colors.green;
        labelText = "📅 Event";
        break;
      case 'Tip':
      default:
        labelColor = Colors.blue;
        labelText = "💡 Safety Tip";
    }

    return Text(
      labelText,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: labelColor,
        fontSize: 16,
      ),
    );
  }
}
