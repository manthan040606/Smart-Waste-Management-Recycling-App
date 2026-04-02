class WasteLog {
  final String id;
  final String category; // organic, plastic, e-waste
  final String description;
  final double quantityKg;
  final DateTime timestamp;

  WasteLog({
    required this.id,
    required this.category,
    required this.description,
    required this.quantityKg,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'quantityKg': quantityKg,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WasteLog.fromMap(Map<String, dynamic> map) {
    return WasteLog(
      id: map['id'],
      category: map['category'],
      description: map['description'],
      quantityKg: map['quantityKg'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
