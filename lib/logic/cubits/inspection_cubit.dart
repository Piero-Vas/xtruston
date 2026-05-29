import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_flutter/domain/models/inspection_model.dart';
import 'package:test_flutter/domain/ports/inspection_repository_port.dart';

// --- ESTADOS ---
abstract class InspectionState {}

class InspectionInitial extends InspectionState {}

class InspectionLoading extends InspectionState {}

class InspectionLoaded extends InspectionState {
  final List<InspectionModel> inspections;
  InspectionLoaded(this.inspections);
}

class InspectionError extends InspectionState {
  final String message;
  InspectionError(this.message);
}

// --- CUBIT ---
class InspectionCubit extends Cubit<InspectionState> {
  final InspectionRepositoryPort _repository;

  InspectionCubit(this._repository) : super(InspectionInitial());

  /// Carga todas las inspecciones desde la base de datos local
  void loadInspections() {
    try {
      emit(InspectionLoading());
      final inspections = _repository.getAllInspections();
      emit(InspectionLoaded(inspections));
    } catch (e) {
      emit(InspectionError('Error al cargar inspecciones: $e'));
    }
  }

  /// Agrega una nueva inspección localmente
  Future<void> addInspection(InspectionModel inspection) async {
    try {
      await _repository.saveInspection(inspection);
      loadInspections();
    } catch (e) {
      emit(InspectionError('Error al guardar la inspección: $e'));
    }
  }

  /// Actualiza la observación de una inspección.
  /// Al modificarse localmente, cambia su estado a 'pending' para forzar su sincronización.
  Future<void> updateObservation(String id, String newObservation) async {
    try {
      final inspection = await _repository.getInspection(id);
      if (inspection != null) {
        final updated = inspection.copyWith(
          observation: newObservation,
          status: 'pending', // Revertimos a pendiente al ser modificada
        );
        await _repository.saveInspection(updated);
        loadInspections();
      }
    } catch (e) {
      emit(InspectionError('Error al actualizar observación: $e'));
    }
  }
}
