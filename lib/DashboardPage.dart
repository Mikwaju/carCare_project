import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.blue[900], // Background color for top items
              width: double.infinity, // Ensures it spans the full width
              padding: const EdgeInsets.all(16.0), // Padding inside the blue area
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "IST 2025, Saloon Car",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text for visibility
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // Add your notification action here
                            },
                            icon: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Navigate to MapsScreen when the map icon is clicked
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.map,
                              color: Colors.white,
                            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.lock, color: Colors.blue),
        title: const Text(
          "Door Closed",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Door Status - Today 8:00am"),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }

  Widget _buildBatteryChart() {
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
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: const [
                        FlSpot(0, 12),
                        FlSpot(1, 13.5),
                        FlSpot(2, 13),
                        FlSpot(3, 12.8),
                        FlSpot(4, 12.5),
                        FlSpot(5, 12),
                      ],
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        backgroundColor: Colors.blue[900],
      ),
      body: const Center(
        child: Text(
          "Map Screen - Add your map here!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}