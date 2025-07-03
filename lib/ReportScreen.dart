import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? selectedMonth;
  String? selectedFormat = 'PDF';
  String report = "No report generated yet";

  final List<String> months = [
    'Current Month',
    'January 2025', 'February 2025', 'March 2025', 'April 2025',
    'May 2025', 'June 2025', 'July 2025', 'August 2025',
    'September 2025', 'October 2025', 'November 2025', 'December 2025'
  ];

  final List<Map<String, dynamic>> sensorData = [
    for (int i = 1; i <= 30; i++)
      {
        'date': '2025-06-${i.toString().padLeft(2, '0')}',
        'voltage': 12 + (i % 3) * 0.1,
        'latitude': -6.6689 + (i % 5) * 0.0001,
        'longitude': 39.1839 + (i % 5) * 0.0001,
        'doorStatus': i % 2 == 0 ? 'Door Opened' : 'Door Closed'
      },
    {
      'date': '2025-07-01',
      'voltage': 11.9,
      'latitude': -6.669,
      'longitude': 39.184,
      'doorStatus': 'Door Closed'
    },
    {
      'date': '2025-07-02',
      'voltage': 12.1,
      'latitude': -6.771440,
      'longitude': 39.240175,
      'doorStatus': 'Door Closed'
    },
    // {
    //   'date': '2025-07-03',
    //   'voltage': 12.05,
    //   'latitude': -6.6687,
    //   'longitude': 39.1838,
    //   'doorStatus': 'Door Closed'
    // },
  ];

  Future<void> _generateAndDownloadReport() async {
    if (selectedMonth == null) {
      setState(() {
        report = "Please select a month";
      });
      return;
    }

    final selectedMonthIndex = months.indexOf(selectedMonth!) - 1;
    final targetMonth = selectedMonthIndex < 0 ? DateTime.now().month : selectedMonthIndex + 1;

    final filtered = sensorData.where((entry) =>
    DateTime.parse(entry['date']).month == targetMonth
    ).toList();

    if (filtered.isEmpty) {
      setState(() {
        report = "No data available for $selectedMonth";
      });
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/report_${selectedMonth!.replaceAll(' ', '_')}.${selectedFormat!.toLowerCase()}';

    if (selectedFormat == 'PDF') {
      final pdf = pw.Document();
      pdf.addPage(pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text("Monthly Report - $selectedMonth", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Date', 'Voltage', 'Latitude', 'Longitude', 'Door Status'],
            data: filtered.map((e) => [
              e['date'],
              e['voltage'].toString(),
              e['latitude'].toString(),
              e['longitude'].toString(),
              e['doorStatus']
            ]).toList(),
          )
        ],
      ));
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(filePath);
    } else if (selectedFormat == 'Excel') {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];
      sheet.appendRow(['Date', 'Voltage', 'Latitude', 'Longitude', 'Door Status']);
      for (var e in filtered) {
        sheet.appendRow([
          e['date'], e['voltage'], e['latitude'], e['longitude'], e['doorStatus']
        ]);
      }
      final fileBytes = excel.save();
      final file = File(filePath);
      await file.writeAsBytes(fileBytes!);
      await OpenFile.open(filePath);
    }

    setState(() {
      report = "Report for $selectedMonth generated successfully.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Report")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Month',
                border: OutlineInputBorder(),
              ),
              value: selectedMonth,
              items: months.map((month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('PDF'),
                    value: 'PDF',
                    groupValue: selectedFormat,
                    onChanged: (value) {
                      setState(() {
                        selectedFormat = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Excel'),
                    value: 'Excel',
                    groupValue: selectedFormat,
                    onChanged: (value) {
                      setState(() {
                        selectedFormat = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _generateAndDownloadReport,
                child: const Text("Generate Report"),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(report))),
          ],
        ),
      ),
    );
  }
}
