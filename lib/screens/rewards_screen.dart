import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/notification_badge.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards Program'), centerTitle: true, actions: const [NotificationBadge()]),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          int points = provider.totalPoints;
          
          return Padding(
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
                      children: [
                        Text(
                          '$points',
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const Text(
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
                       _buildRewardItem(context, 'Free Eco-Bag', 50, points),
                       const Divider(),
                       _buildRewardItem(context, '\$5 Coffee Voucher', 200, points),
                       const Divider(),
                       _buildRewardItem(context, 'City Transit Pass', 500, points),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardItem(BuildContext context, String title, int cost, int userPoints) {
    bool canRedeem = userPoints >= cost;

    return ListTile(
      leading: Icon(Icons.card_giftcard, color: canRedeem ? Colors.orange : Colors.grey),
      title: Text(title, style: TextStyle(fontWeight: canRedeem ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text('$cost Points'),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canRedeem ? Colors.green : Colors.grey.shade300,
          foregroundColor: canRedeem ? Colors.white : Colors.grey,
        ),
        onPressed: canRedeem ? () async {
          await Provider.of<AppProvider>(context, listen: false).redeemReward(cost);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully Redeemed $title!'), backgroundColor: Colors.green),
          );
        } : null, 
        child: const Text('Redeem')
      ),
    );
  }
}
