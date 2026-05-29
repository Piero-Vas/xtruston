import '../models/inspection_model.dart';

abstract class ApiServicePort {
  /// Envía la metadata de la inspección y foto al backend mock.
  /// Retorna el código de respuesta (ej: 200 para éxito, 409 para conflicto, 500 para error del servidor).
  Future<int> uploadInspection(InspectionModel inspection);
}
