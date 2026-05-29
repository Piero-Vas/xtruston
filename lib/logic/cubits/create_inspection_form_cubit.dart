import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:test_flutter/domain/models/inspection_model.dart';
import 'package:test_flutter/logic/cubits/inspection_cubit.dart';
import 'package:test_flutter/logic/cubits/sync_cubit.dart';

// --- ESTADOS ---
abstract class CreateInspectionFormState {}

class CreateInspectionFormInitial extends CreateInspectionFormState {}

class CreateInspectionFormSubmitting extends CreateInspectionFormState {}

class CreateInspectionFormSuccess extends CreateInspectionFormState {}

class CreateInspectionFormError extends CreateInspectionFormState {
  final String error;
  CreateInspectionFormError(this.error);
}

// --- CUBIT ---
class CreateInspectionFormCubit extends Cubit<CreateInspectionFormState> {
  final InspectionCubit _inspectionCubit;
  final SyncCubit _syncCubit;
  final _uuid = const Uuid();

  CreateInspectionFormCubit({
    required this._inspectionCubit,
    required this._syncCubit,
  })  : super(CreateInspectionFormInitial());

  /// Valida los datos de entrada y, si son correctos, registra la inspección e inicia la sincronización.
  void submit({
    required String name,
    required String? category,
    required String? photoPath,
    required String observation,
  }) {
    if (name.trim().isEmpty) {
      emit(CreateInspectionFormError('Por favor ingresa el nombre del lugar.'));
      return;
    }
    if (category == null) {
      emit(CreateInspectionFormError('Por favor selecciona una categoría.'));
      return;
    }
    if (photoPath == null) {
      emit(CreateInspectionFormError('Es obligatorio tomar una foto para registrar la inspección.'));
      return;
    }

    emit(CreateInspectionFormSubmitting());

    try {
      final newInspection = InspectionModel(
        id: _uuid.v4(),
        name: name.trim(),
        category: category,
        photoPath: photoPath,
        observation: observation.trim(),
        status: 'pending', // Inicia siempre como pendiente de sincronización
        createdAt: DateTime.now(),
      );

      // Guardar localmente
      _inspectionCubit.addInspection(newInspection);
      
      // Intentar sincronización en segundo plano de inmediato
      _syncCubit.syncPendingQueue();
      
      emit(CreateInspectionFormSuccess());
    } catch (e) {
      emit(CreateInspectionFormError('Error al guardar la inspección: $e'));
    }
  }
}
