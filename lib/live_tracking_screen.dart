import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  LatLng? currentPosition;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
    sendHelpMessage(); // Sends SOS message on screen load
  }

  // 🔄 Live location stream
  void _startLiveTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update every 5 meters
      ),
    ).listen((Position pos) {
      LatLng newPos = LatLng(pos.latitude, pos.longitude);
      setState(() {
        currentPosition = newPos;
      });

      // Move the map to follow the user
      mapController.move(newPos, mapController.zoom);
    });
  }

  // 📥 Load trusted contact numbers from SharedPreferences
  Future<List<String>> _loadTrustedContactNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedContacts = prefs.getStringList('trustedContacts');

    if (savedContacts != null) {
      List<String> phoneNumbers =
          savedContacts
              .map((c) => json.decode(c)) // decode JSON string
              .map<String>(
                (decoded) => decoded['phone'].toString(),
              ) // get phone
              .toList();
      return phoneNumbers;
    }
    return [];
  }

  // 📤 Send SOS to saved trusted contacts
  void sendHelpMessage() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String message =
          "🚨 I'm in danger. Please help me!\nMy current location: https://maps.google.com/?q=${position.latitude},${position.longitude}";

      List<String> trustedContacts = await _loadTrustedContactNumbers();

      if (trustedContacts.isEmpty) {
        print("⚠️ No trusted contacts found!");
        return;
      }

      String contactsString = trustedContacts.join(',');
      final Uri smsUri = Uri.parse(
        'sms:$contactsString?body=${Uri.encodeComponent(message)}',
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        print("❌ Could not launch SMS to trusted contacts");
      }
    } catch (e) {
      print("❌ Error sending SOS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: Colors.pink,
      ),
      body:
          currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: currentPosition,
                  zoom: 16.0,
                  interactiveFlags: InteractiveFlag.all,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.hersafe',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentPosition!,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }
}
