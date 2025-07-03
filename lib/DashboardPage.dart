import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:carcare/MapScreen.dart';
import 'package:carcare/ProfileScreen.dart';
import 'package:carcare/ReportScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String carType = "Loading...";
  Map<String, double> tirePressures = {
    "leftForward": 0.0,
    "rightForward": 0.0,
    "leftRear": 0.0,
    "rightRear": 0.0,
  }; // Store tire pressures
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool _wasLowBatteryNotified = false;
  bool _wasDoorOpenNotified = false;
  String _latestDoorStatus = "Unknown";
  double? _latestVoltage;

  @override
  void initState() {
    super.initState();
    print("Current user UID: ${_auth.currentUser!.uid}");
    _fetchUserData();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('car_care_channel', 'Car Care Alerts',
        importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics);
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            carType = doc['carType'] ?? "Unknown Car";
            Map<String, dynamic>? pressureData = doc['tirePressure'] as Map<String, dynamic>?;
            if (pressureData != null) {
              tirePressures['leftForward'] = (pressureData['leftForward'] ?? 0.0).toDouble();
              tirePressures['rightForward'] = (pressureData['rightForward'] ?? 0.0).toDouble();
              tirePressures['leftRear'] = (pressureData['leftRear'] ?? 0.0).toDouble();
              tirePressures['rightRear'] = (pressureData['rightRear'] ?? 0.0).toDouble();
            }
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
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
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
                              String message = _latestVoltage != null
                                  ? "Door: $_latestDoorStatus\nBattery: ${_latestVoltage!.toStringAsFixed(2)} V"
                                  : "Door: $_latestDoorStatus\nBattery: No data";
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            },
                            icon: const Icon(Icons.notifications, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_auth.currentUser != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MapsScreen(userId: _auth.currentUser!.uid),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please log in to view the map")),
                                );
                              }
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
        if (snapshot.hasError) {
          print("Status snapshot error: ${snapshot.error}");
          return const Card(
            child: ListTile(
              leading: Icon(Icons.lock, color: Colors.blue),
              title: Text("Error loading status"),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          print("No status snapshot data at /users/${_auth.currentUser!.uid}/vehicleData/status");
          return const Card(
            child: ListTile(
              leading: Icon(Icons.lock, color: Colors.blue),
              title: Text("No door status available"),
            ),
          );
        }
        dynamic data = snapshot.data!.snapshot.value;
        String doorStatus = "Unknown";
        String timestamp = "N/A";
        if (data is Map<dynamic, dynamic>) {
          doorStatus = data['doorStatus'] ?? "Unknown";
          timestamp = data['timestamp'] ?? "N/A";
          _latestDoorStatus = doorStatus;
          if (doorStatus == "Door Opened" && !_wasDoorOpenNotified) {
            _showNotification("Door Alert", "Door has been opened at $timestamp");
            _wasDoorOpenNotified = true;
          } else if (doorStatus != "Door Opened") {
            _wasDoorOpenNotified = false;
          }
        }
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
          .child('vehicleData/sensors')
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Voltage snapshot error: ${snapshot.error}");
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Error loading voltage data"),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          print('No voltage data at /users/${_auth.currentUser!.uid}/vehicleData/sensors');
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No voltage data available"),
            ),
          );
        }
        dynamic sensorsData = snapshot.data!.snapshot.value;
        List<double> voltageHistory = [];
        if (sensorsData is Map<dynamic, dynamic>) {
          if (sensorsData['voltageHistory'] != null) {
            dynamic history = sensorsData['voltageHistory'];
            if (history is Map<dynamic, dynamic>) {
              history.forEach((key, value) {
                if (value is num) {
                  voltageHistory.add(value.toDouble());
                }
              });
            } else if (history is List) {
              for (var value in history) {
                if (value is num) {
                  voltageHistory.add(value.toDouble());
                }
              }
            }
          }
          if (voltageHistory.isNotEmpty) {
            double latestVoltage = voltageHistory.last;
            _latestVoltage = latestVoltage;
            if (latestVoltage < 12.0 && !_wasLowBatteryNotified) {
              _showNotification(
                  "Low Battery", "Voltage is ${latestVoltage.toStringAsFixed(2)} V - Charge soon!");
              _wasLowBatteryNotified = true;
            } else if (latestVoltage >= 12.0) {
              _wasLowBatteryNotified = false;
            }
          }
        }
        if (voltageHistory.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No valid voltage data"),
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
                  "Vehicle Battery Voltage",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                            interval: 1,
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}V',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                            interval: 2,
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 2,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 0.5,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 0.5,
                          );
                        },
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: Colors.blue[700]!,
                          barWidth: 2,
                          spots: voltageHistory
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                              radius: 3,
                              color: Colors.blue[700]!,
                              strokeWidth: 1,
                              strokeColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: 16,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(2)}V',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            }).toList();
                          },
                        ),
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
              children: [
                _TirePressureWidget(
                    title: "Left Forward Tire",
                    pressure: tirePressures['leftForward'] ?? 0.0),
                _TirePressureWidget(
                    title: "Right Forward Tire",
                    pressure: tirePressures['rightForward'] ?? 0.0),
                _TirePressureWidget(
                    title: "Left Rear Tire",
                    pressure: tirePressures['leftRear'] ?? 0.0),
                _TirePressureWidget(
                    title: "Right Rear Tire",
                    pressure: tirePressures['rightRear'] ?? 0.0),
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
        if (snapshot.hasError) {
          print("GPS snapshot error: ${snapshot.error}");
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Error loading GPS data"),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          print("No GPS snapshot data at /users/${_auth.currentUser!.uid}/vehicleData/sensors");
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No GPS data available"),
            ),
          );
        }
        dynamic data = snapshot.data!.snapshot.value;
        double latitude = 0.0;
        double longitude = 0.0;
        if (data is Map<dynamic, dynamic>) {
          latitude = (data['latitude'] ?? 0.0).toDouble();
          longitude = (data['longitude'] ?? 0.0).toDouble();
        }
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