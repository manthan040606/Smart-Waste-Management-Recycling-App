import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards Program')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 4),
                ),
                child: Column(
                  children: const [
                    Text(
                      '250',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    Text(
                      'Points',
                      style: TextStyle(fontSize: 20, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Convert points to rewards!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                   ListTile(
                     leading: const Icon(Icons.card_giftcard, color: Colors.orange),
                     title: const Text('\$5 Coffee Voucher'),
                     subtitle: const Text('200 Points'),
                     trailing: ElevatedButton(
                       onPressed: () {}, 
                       child: const Text('Redeem')
                     ),
                   ),
                   const Divider(),
                   ListTile(
                     leading: const Icon(Icons.directions_bus, color: Colors.blue),
                     title: const Text('City Transit Pass'),
                     subtitle: const Text('500 Points'),
                     trailing: ElevatedButton(
                       onPressed: null, 
                       child: const Text('Redeem')
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
