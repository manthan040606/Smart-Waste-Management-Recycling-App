class PickupSchedule {
  final String id;
  final DateTime scheduledTime;
  final String address;
  final double latitude;
  final double longitude;
  final String status; // 'pending', 'completed'

  PickupSchedule({
    required this.id,
    required this.scheduledTime,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduledTime': scheduledTime.toIso8601String(),
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
  }

  factory PickupSchedule.fromMap(Map<String, dynamic> map) {
    return PickupSchedule(
      id: map['id'],
      scheduledTime: DateTime.parse(map['scheduledTime']),
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      status: map['status'] ?? 'pending',
    );
  }
}
