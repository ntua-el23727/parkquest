class ParkedCar {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime savedAt;
  final String? note;
  final String? imagePath;
  final DateTime leftAt;
  final bool sharedPosition;

  ParkedCar({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.savedAt,
    this.note,
    this.imagePath,
    required this.leftAt,
    this.sharedPosition = false,
  });

  ParkedCar copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? savedAt,
    String? note,
    String? imagePath,
    DateTime? leftAt,
    bool? sharedPosition,
  }) {
    return ParkedCar(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      savedAt: savedAt ?? this.savedAt,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      leftAt: leftAt ?? this.leftAt,
      sharedPosition: sharedPosition ?? this.sharedPosition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'savedAt': savedAt.toIso8601String(),
      'note': note,
      'imagePath': imagePath,
      'leftAt': leftAt.toIso8601String(),
    };
  }

  factory ParkedCar.fromJson(Map<String, dynamic> json) {
    return ParkedCar(
      id: json['id'] ?? '',
      latitude: (json['latitude'] is String)
          ? double.parse(json['latitude'])
          : json['latitude'],
      longitude: (json['longitude'] is String)
          ? double.parse(json['longitude'])
          : json['longitude'],
      address: json['address'] ?? '',
      savedAt: DateTime.parse(json['savedAt']),
      note: json['note'],
      imagePath: json['imagePath'],
      leftAt: DateTime.parse(json['leftAt']),
    );
  }
}
