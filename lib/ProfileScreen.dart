import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login signup/screens/LoginPage.dart'; // Update with your actual LoginScreen path

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "Loading...";
  String carType = "Loading...";
  String email = "Loading...";
  bool _isLoading = true;
  String? _errorMessage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();
  bool _isDebugMode = true;

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      if (_isDebugMode) print("User logged in, UID: ${_auth.currentUser!.uid}");
      _fetchUserData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "No user logged in. Please log in again.";
      });
      if (_isDebugMode) print("No user logged in.");
    }
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        if (_isDebugMode) print("Fetching data for UID: $uid");
        DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          setState(() {
            username = doc['username'] ?? user.displayName ?? "No Name";
            carType = doc['carType'] ?? "Unknown Car";
            email = user.email ?? "No Email";
            _usernameController.text = username;
            _carTypeController.text = carType;
            _isLoading = false;
          });
          if (_isDebugMode) print("Fetched data: username=$username, carType=$carType, email=$email");
        } else {
          setState(() {
            username = user.displayName ?? "No Name";
            email = user.email ?? "No Email";
            _usernameController.text = username;
            _carTypeController.text = carType;
            _isLoading = false;
            _errorMessage = "User profile not found in Firestore. Please save details.";
          });
          if (_isDebugMode) print("No document found for UID: $uid");
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "No user logged in.";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load profile data: $e";
      });
    }
  }

  Future<void> _saveDetails() async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user logged in. Please log in again.")),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      String uid = user.uid;
      if (_isDebugMode) print("Saving data for UID: $uid");
      await _firestore.collection('users').doc(uid).set({
        'username': _usernameController.text,
        'carType': _carTypeController.text,
      }, SetOptions(merge: true));
      if (user.displayName != _usernameController.text) {
        await user.updateDisplayName(_usernameController.text);
      }
      setState(() {
        username = _usernameController.text;
        carType = _carTypeController.text;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details saved successfully")),
      );
      if (_isDebugMode) print("Saved data: username=$username, carType=$carType");
    } catch (e) {
      print("Error saving details: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save details")),
      );
    }
  }

  Future<void> _logout() async {
    try {
      if (_isDebugMode) print("Logging out user with UID: ${_auth.currentUser?.uid}");
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to log out")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveDetails,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30), // prevents keyboard overflow
          child: Padding(
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
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: Text(
                      email,
                      style: const TextStyle(color: Colors.black54),
                    ),
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
                    onPressed: _isLoading ? null : _logout,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _carTypeController.dispose();
    super.dispose();
  }
}
