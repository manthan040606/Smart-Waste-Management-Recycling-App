import 'package:flutter/material.dart';

class RecyclingLocatorScreen extends StatelessWidget {
  const RecyclingLocatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Centers')),
      body: Stack(
        children: [
          Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Text(
                '(Map Placeholder)',
                style: TextStyle(color: Colors.grey, fontSize: 24),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
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
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.red),
                    title: Text('Downtown E-Waste Facility'),
                    subtitle: Text('2.5 miles away'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.red),
                    title: Text('City Plastics Recycling'),
                    subtitle: Text('4.0 miles away'),
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
