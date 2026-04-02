class WasteLog {
  final String id;
  final String category; // organic, plastic, e-waste
  final String description;
  final double quantityKg;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final int points;
  final int syncStatus; // 0 = pending, 1 = synced

  WasteLog({
    required this.id,
    required this.category,
    required this.description,
    required this.quantityKg,
    required this.timestamp,
    this.latitude,
    this.longitude,
    required this.points,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'quantityKg': quantityKg,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'points': points,
      'syncStatus': syncStatus,
    };
  }

  factory WasteLog.fromMap(Map<String, dynamic> map) {
    return WasteLog(
      id: map['id'],
      category: map['category'],
      description: map['description'],
      quantityKg: map['quantityKg'],
      timestamp: DateTime.parse(map['timestamp']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      points: map['points'],
      syncStatus: map['syncStatus'] ?? 0,
    );
  }
}
