import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  final List<Map<String, String>> trustedContacts = [
    {'name': 'Mom', 'phone': '+91 98765 43210'},
    {'name': 'Dad', 'phone': '+91 98765 43211'},
    {'name': 'Best Friend', 'phone': '+91 98765 43212'},
  ];

  void _addContact(String name, String phone) {
    setState(() {
      trustedContacts.add({'name': name, 'phone': phone});
    });
  }

  void _removeContact(int index) {
    setState(() {
      trustedContacts.removeAt(index);
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $phoneNumber')));
    }
  }

  void _showAddContactDialog() {
    String name = '';
    String phone = '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add Trusted Contact"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Name"),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => phone = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (name.isNotEmpty && phone.isNotEmpty) {
                    _addContact(name, phone);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trusted Contacts"),
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
          itemCount: trustedContacts.length,
          itemBuilder: (context, index) {
            final contact = trustedContacts[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.pink.shade100,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.white, size: 30),
                  onPressed: () => _makePhoneCall(contact['phone']!),
                ),
                title: Text(
                  contact['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  contact['phone']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _removeContact(index),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}
