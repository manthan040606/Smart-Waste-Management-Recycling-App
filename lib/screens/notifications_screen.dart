import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).markNotificationsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications & Reminders')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;
          if (notifications.isEmpty) {
            return const Center(child: Text('You have no new notifications!'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.green),
                  title: Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notif.message),
                  trailing: Text(
                    DateFormat('dd MMM hh:mm a').format(notif.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
