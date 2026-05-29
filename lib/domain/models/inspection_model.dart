import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_model.freezed.dart';
part 'inspection_model.g.dart';

@freezed
abstract class InspectionModel with _$InspectionModel {
  const factory InspectionModel({
    required String id,
    required String name,
    required String category,
    required String photoPath,
    required String observation,
    required String status, // 'pending', 'synced', 'conflict'
    required DateTime createdAt,
  }) = _InspectionModel;

  // Constructor privado requerido para definir métodos y getters personalizados
  const InspectionModel._();

  factory InspectionModel.fromJson(Map<String, dynamic> json) =>
      _$InspectionModelFromJson(json);

  // Mapeador auxiliar para mantener compatibilidad con Hive
  factory InspectionModel.fromMap(Map<dynamic, dynamic> map) {
    return InspectionModel.fromJson(Map<String, dynamic>.from(map));
  }

  // Mapeador auxiliar para mantener compatibilidad con el resto del sistema
  Map<String, dynamic> toMap() => toJson();
}
