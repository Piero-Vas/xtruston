import 'package:test_flutter/domain/models/inspection_model.dart';

abstract class InspectionRepositoryPort {
  /// Obtiene todas las inspecciones locales ordenadas por fecha descendente.
  List<InspectionModel> getAllInspections();

  /// Guarda o actualiza un registro de inspección localmente.
  Future<void> saveInspection(InspectionModel inspection);

  /// Obtiene un registro individual por su identificador.
  Future<InspectionModel?> getInspection(String id);

  /// Elimina un registro localmente.
  Future<void> deleteInspection(String id);

  /// Vacía toda la persistencia local.
  Future<void> clearAll();
}
