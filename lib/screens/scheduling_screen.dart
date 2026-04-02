import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule.dart';
import '../providers/app_provider.dart';
import 'package:intl/intl.dart';
import '../widgets/notification_badge.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({Key? key}) : super(key: key);

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _addressController = TextEditingController();
  
  bool _isAuthorityView = false;

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _schedulePickup() async {
    if (_selectedDate == null || _selectedTime == null || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date, time, and enter address')),
      );
      return;
    }

    final scheduledTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final schedule = PickupSchedule(
      id: const Uuid().v4(),
      scheduledTime: scheduledTime,
      address: _addressController.text,
      latitude: 23.0338, // mock coordinate
      longitude: 72.5850, // mock coordinate
      status: 'pending',
    );

    await Provider.of<AppProvider>(context, listen: false).addSchedule(schedule);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pickup scheduled successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _addressController.clear();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Widget _buildUserView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'Schedule a Municipal Waste Pickup',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
             'Select a date and time, and enter your address below.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            leading: const Icon(Icons.calendar_today, color: Colors.green),
            title: Text(_selectedDate == null
                ? 'Select Date'
                : DateFormat('dd MMM yyyy').format(_selectedDate!)),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            leading: const Icon(Icons.access_time, color: Colors.blue),
            title: Text(_selectedTime == null
                ? 'Select Time'
                : _selectedTime!.format(context)),
            onTap: _pickTime,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _schedulePickup,
            icon: const Icon(Icons.airport_shuttle),
            label: const Text('Confirm Pickup', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Track Pickups',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              final schedules = provider.schedules;
              if (schedules.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No pickups scheduled yet.', textAlign: TextAlign.center),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: schedules.length > 5 ? 5 : schedules.length,
                itemBuilder: (context, index) {
                  final sched = schedules[index];
                  bool isPending = sched.status == 'pending';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(
                        isPending ? Icons.local_shipping : Icons.check_circle,
                        color: isPending ? Colors.orange : Colors.green,
                      ),
                      title: Text(DateFormat('dd MMM yyyy, hh:mm a').format(sched.scheduledTime)),
                      subtitle: Text(sched.address),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            sched.status.toUpperCase(),
                            style: TextStyle(
                              color: isPending ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Provider.of<AppProvider>(context, listen: false).deleteSchedule(sched.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorityView() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final schedules = provider.schedules;
        
        if (schedules.isEmpty) {
          return const Center(child: Text('No pickups scheduled.'));
        }

        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final sched = schedules[index];
            bool isPending = sched.status == 'pending';
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  isPending ? Icons.pending_actions : Icons.check_circle,
                  color: isPending ? Colors.orange : Colors.green,
                  size: 40,
                ),
                title: Text(sched.address, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(sched.scheduledTime)}\nStatus: ${sched.status.toUpperCase()}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Provider.of<AppProvider>(context, listen: false).deleteSchedule(sched.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Pickup'),
        centerTitle: true,
        actions: [
          const NotificationBadge(),
          Row(
            children: [
              const Text('Admin', style: TextStyle(fontSize: 12)),
              Switch(
                value: _isAuthorityView,
                activeColor: Colors.white,
                onChanged: (val) {
                  setState(() {
                    _isAuthorityView = val;
                  });
                },
              ),
            ],
          )
        ],
      ),
      body: _isAuthorityView ? _buildAuthorityView() : _buildUserView(),
    );
  }
}
