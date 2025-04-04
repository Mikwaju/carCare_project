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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("IST 2025, Saloon Car", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildStatusCard(),
              const SizedBox(height: 10),
              _buildBatteryChart(),
              const SizedBox(height: 10),
              _buildTirePressureSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.lock, color: Colors.blue),
        title: const Text("Door Closed", style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text("Vehicle Battery Voltage", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: [
                        const FlSpot(0, 12),
                        const FlSpot(1, 13.5),
                        const FlSpot(2, 13),
                        const FlSpot(3, 12.8),
                        const FlSpot(4, 12.5),
                        const FlSpot(5, 12),
                      ],
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
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
            const Text("Tire Pressure", style: TextStyle(fontWeight: FontWeight.bold)),
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
        Text("${pressure.toStringAsFixed(1)} PSI", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
