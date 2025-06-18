import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class MapsScreen extends StatefulWidget {
  final String userId;

  const MapsScreen({super.key, required this.userId});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  bool _isLoading = true;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadVehicleLocation();
  }

  void _loadVehicleLocation() {
    FirebaseDatabase.instance
        .ref()
        .child('users/${widget.userId}/vehicleData/sensors')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final lat = data['latitude'] as num? ?? 0.0;
        final lon = data['longitude'] as num? ?? 0.0;
        setState(() {
          _currentPosition = LatLng(lat.toDouble(), lon.toDouble());
          _markers = {
            Marker(
              markerId: const MarkerId('vehicle'),
              position: _currentPosition,
              infoWindow: const InfoWindow(title: 'Vehicle Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          };
          _isLoading = false;
        });
        if (!_isLoading) {
          _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
        }
      } else {
        print('No GPS data found in Firebase');
        setState(() {
          _isLoading = false;
        });
      }
    }, onError: (error) {
      print('Firebase error: $error');
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Location"),
        backgroundColor: Colors.blue[900],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition.latitude == 0.0 && _currentPosition.longitude == 0.0
          ? const Center(child: Text('No vehicle location data available'))
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          if (_currentPosition.latitude != 0.0 && _currentPosition.longitude != 0.0) {
            _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
          }
        },
        markers: _markers,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}