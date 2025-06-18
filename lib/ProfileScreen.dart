import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login signup/screens/LoginPage.dart';// Replace with your actual LoginScreen path

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String carType = "Loading...";
  String name = "Loading...";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            carType = doc['carType'] ?? "Unknown Car";
            name = doc['name'] ?? user.displayName ?? "No Name";
            _nameController.text = name;
            _carTypeController.text = carType;
          });
        } else {
          setState(() {
            name = user.displayName ?? "No Name";
            _nameController.text = name;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _saveDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'carType': _carTypeController.text,
        });
        if (user.displayName != _nameController.text) {
          await user.updateDisplayName(_nameController.text);
        }
        setState(() {
          name = _nameController.text;
          carType = _carTypeController.text;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Details saved")));
      } catch (e) {
        print("Error saving details: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save details")));
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDetails,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: Text(_auth.currentUser?.email ?? "No Email"),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.blue),
                title: TextField(
                  controller: _carTypeController,
                  decoration: const InputDecoration(labelText: "Car Type"),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}