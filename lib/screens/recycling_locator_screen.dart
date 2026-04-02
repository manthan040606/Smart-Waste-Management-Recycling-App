import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class RecyclingLocatorScreen extends StatefulWidget {
  const RecyclingLocatorScreen({Key? key}) : super(key: key);

  @override
  State<RecyclingLocatorScreen> createState() => _RecyclingLocatorScreenState();
}

class _RecyclingLocatorScreenState extends State<RecyclingLocatorScreen> {
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  
  final List<Marker> _markers = [];
  final List<Map<String, dynamic>> _centers = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      } 

      Position position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );
      
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _generateDummyCenters(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
         setState(() {
           // Provide a default mockup for emulator or if permission throws natively
           _currentPosition = const LatLng(23.0338, 72.5850); 
           _generateDummyCenters(23.0338, 72.5850);
           _errorMessage = 'Location fetch failed. Using mock location.';
           _isLoading = false;
         });
      }
    }
  }

  void _generateDummyCenters(double lat, double lng) {
    final random = Random();
    
    for (int i = 0; i < 4; i++) {
        double latOffset = (random.nextDouble() - 0.5) * 0.1;
        double lngOffset = (random.nextDouble() - 0.5) * 0.1;
        
        LatLng centerLoc = LatLng(lat + latOffset, lng + lngOffset);
        
        _centers.add({
          'name': 'Recycling Center ${i + 1}',
          'distance': '${(random.nextDouble() * 5).toStringAsFixed(1)} miles away',
          'location': centerLoc,
        });

        _markers.add(
          Marker(
            point: centerLoc,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.green, size: 40),
          ),
        );
    }
    
    // user marker
    _markers.add(
      Marker(
        point: LatLng(lat, lng),
        width: 40,
        height: 40,
        child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Centers')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty && _currentPosition == null
          ? Center(child: Text(_errorMessage))
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 250,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                         const Padding(
                           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                           child: Text('Closest Locations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                         ),
                         Expanded(
                           child: ListView.builder(
                             itemCount: _centers.length,
                             itemBuilder: (context, index) {
                               return ListTile(
                                 leading: const Icon(Icons.store, color: Colors.green),
                                 title: Text(_centers[index]['name']),
                                 subtitle: Text(_centers[index]['distance']),
                                 trailing: IconButton(
                                   icon: const Icon(Icons.directions, color: Colors.blue),
                                   onPressed: () {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Navigation feature mocked.')),
                                     );
                                   },
                                 ),
                               );
                             },
                           ),
                         ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
