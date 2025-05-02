import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carcare/MapScreen.dart'; // Replace with your actual MapsScreen path

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String carType = "Loading..."; // Default while fetching
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch carType from Firestore
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            carType = doc['carType'] ?? "Unknown Car";
          });
        } else {
          print("No user data in Firestore");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print("No user logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          // Add navigation logic if needed (e.g., to Report or Profile screens)
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.blue[900],
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        carType,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Notifications not implemented yet")),
                              );
                            },
                            icon: const Icon(Icons.notifications, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.map, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildStatusCard(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildBatteryChart(),
                  const SizedBox(height: 10),
                  _buildTirePressureSection(),
                  const SizedBox(height: 10),
                  _buildGPSSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return StreamBuilder<DatabaseEvent>(
      stream: _database
          .ref()
          .child('users')
          .child(_auth.currentUser!.uid)
          .child('vehicleData/status')
          .onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          print("No status snapshot data");
          return const Card(
            child: ListTile(
              leading: Icon(Icons.lock, color: Colors.blue),
              title: Text("Loading..."),
            ),
          );
        }
        print("Status data: ${snapshot.data!.snapshot.value}");
        var data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        String doorStatus = data['doorStatus'] ?? "Unknown";
        String timestamp = data['timestamp'] ?? "N/A";
        return Card(
          child: ListTile(
            leading: const Icon(Icons.lock, color: Colors.blue),
            title: Text(
              doorStatus,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Door Status - $timestamp"),
            trailing: doorStatus == "Door Closed"
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.error, color: Colors.red),
          ),
        );
      },
    );
  }

  Widget _buildBatteryChart() {
    return StreamBuilder<DatabaseEvent>(
      stream: _database
          .ref()
          .child('users')
          .child(_auth.currentUser!.uid)
          .child('vehicleData/sensors/voltageHistory')
          .onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          print("No voltage history data");
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Loading battery data..."),
            ),
          );
        }
        print("Voltage history: ${snapshot.data!.snapshot.value}");
        List<dynamic> voltageHistory = snapshot.data!.snapshot.value as List<dynamic>;
        List<FlSpot> spots = voltageHistory
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), (e.value as num).toDouble()))
            .toList();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Vehicle Battery Voltage",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            interval: 1,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}V',
                              style: const TextStyle(fontSize: 10),
                            ),
                            interval: 1,
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
                      gridData: FlGridData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: Colors.blue,
                          spots: spots,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                      ],
                      minY: 10,
                      maxY: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTirePressureSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tire Pressure",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
              children: const [
                _TirePressureWidget(title: "Left Forward Tire", pressure: 34.0),
                _TirePressureWidget(title: "Right Forward Tire", pressure: 34.5),
                _TirePressureWidget(title: "Left Rear Tire", pressure: 33.8),
                _TirePressureWidget(title: "Right Rear Tire", pressure: 34.2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSSection() {
    return StreamBuilder<DatabaseEvent>(
      stream: _database
          .ref()
          .child('users')
          .child(_auth.currentUser!.uid)
          .child('vehicleData/sensors')
          .onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          print("No GPS snapshot data");
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Loading GPS data..."),
            ),
          );
        }
        print("GPS data: ${snapshot.data!.snapshot.value}");
        var data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        double latitude = (data['latitude'] ?? 0.0).toDouble();
        double longitude = (data['longitude'] ?? 0.0).toDouble();
        if (latitude == 0.0 && longitude == 0.0) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Waiting for GPS fix..."),
            ),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "GPS Location",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Latitude: ${latitude.toStringAsFixed(6)}"),
                Text("Longitude: ${longitude.toStringAsFixed(6)}"),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TirePressureWidget extends StatelessWidget {
  final String title;
  final double pressure;

  const _TirePressureWidget({required this.title, required this.pressure});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: pressure / 40,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${pressure.toStringAsFixed(1)} PSI",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}