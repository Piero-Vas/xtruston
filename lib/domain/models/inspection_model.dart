class InspectionModel {
  final String id;
  final String name;
  final String category;
  final String photoPath;
  final String observation;
  final String status; // 'pending', 'synced', 'conflict'
  final DateTime createdAt;

  InspectionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.photoPath,
    required this.observation,
    required this.status,
    required this.createdAt,
  });

  InspectionModel copyWith({
    String? id,
    String? name,
    String? category,
    String? photoPath,
    String? observation,
    String? status,
    DateTime? createdAt,
  }) {
    return InspectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      photoPath: photoPath ?? this.photoPath,
      observation: observation ?? this.observation,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'photoPath': photoPath,
      'observation': observation,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InspectionModel.fromMap(Map<dynamic, dynamic> map) {
    return InspectionModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      photoPath: map['photoPath'] as String,
      observation: map['observation'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'observation': observation,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
