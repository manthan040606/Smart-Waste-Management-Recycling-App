import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/notifications_screen.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
            ),
            if (provider.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text(
                    '${provider.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
