import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:test_flutter/domain/ports/api_service_port.dart';
import 'package:test_flutter/domain/ports/connectivity_service_port.dart';
import 'package:test_flutter/domain/ports/inspection_repository_port.dart';
import 'package:test_flutter/logic/cubits/inspection_cubit.dart';

// --- ESTADOS ---
abstract class SyncState {}

class SyncInitial extends SyncState {}

class Syncing extends SyncState {
  final int pendingCount;
  Syncing(this.pendingCount);
}

class SyncSuccess extends SyncState {
  final String message;
  SyncSuccess(this.message);
}

class SyncFailed extends SyncState {
  final String error;
  SyncFailed(this.error);
}

// --- CUBIT ---
class SyncCubit extends Cubit<SyncState> {
  final InspectionRepositoryPort _repository;
  final ApiServicePort _apiService;
  final ConnectivityServicePort _connectivityService;
  final InspectionCubit _inspectionCubit;

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SyncCubit(
    this._repository,
    this._apiService,
    this._connectivityService,
    this._inspectionCubit,
  ) : super(SyncInitial()) {
    // Escucha cambios de conectividad
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        syncPendingQueue();
      }
    });
  }

  /// Procesa secuencialmente todos los registros pendientes de sincronización
  Future<void> syncPendingQueue() async {
    if (_isSyncing) return;

    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      emit(SyncFailed('No hay conexión a internet para iniciar sincronización.'));
      return;
    }

    final allInspections = _repository.getAllInspections();
    final pendingInspections = allInspections
        .where((ins) => ins.status == 'pending')
        .toList();

    if (pendingInspections.isEmpty) {
      return;
    }

    _isSyncing = true;
    emit(Syncing(pendingInspections.length));

    int syncedCount = 0;
    int conflictCount = 0;
    bool networkFailure = false;

    for (final inspection in pendingInspections) {
      try {
        final statusCode = await _apiService.uploadInspection(inspection);

        if (statusCode == 200 || statusCode == 201) {
          // Éxito: Marcar como sincronizada
          final updated = inspection.copyWith(status: 'synced');
          await _repository.saveInspection(updated);
          syncedCount++;
        } else if (statusCode == 409) {
          // Conflicto de negocio permanente
          final updated = inspection.copyWith(status: 'conflict');
          await _repository.saveInspection(updated);
          conflictCount++;
        } else {
          // Error de servidor / red temporal (500, 503, etc.): Mantiene pendiente y detiene la cola
          networkFailure = true;
          break;
        }
      } catch (e) {
        // Excepción de red real
        networkFailure = true;
        break;
      }
    }

    // Actualiza la lista en el InspectionCubit
    _inspectionCubit.loadInspections();
    _isSyncing = false;

    if (networkFailure) {
      emit(SyncFailed('La sincronización se detuvo debido a un fallo de red o del servidor. Quedan elementos pendientes.'));
    } else if (conflictCount > 0) {
      emit(SyncSuccess('Sincronizados: $syncedCount. Conflictos detectados: $conflictCount.'));
    } else {
      emit(SyncSuccess('Todos los registros pendientes se sincronizaron con éxito ($syncedCount).'));
    }
  }

  /// Permite sincronizar manualmente una inspección en particular (ej. forzar resolución de conflicto o reintento de pendiente)
  Future<void> syncSingle(String id) async {
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      emit(SyncFailed('No hay conexión a internet.'));
      return;
    }

    final inspection = await _repository.getInspection(id);
    if (inspection == null) return;

    emit(Syncing(1));
    try {
      final statusCode = await _apiService.uploadInspection(inspection);
      if (statusCode == 200 || statusCode == 201) {
        final updated = inspection.copyWith(status: 'synced');
        await _repository.saveInspection(updated);
        _inspectionCubit.loadInspections();
        emit(SyncSuccess('Inspección sincronizada exitosamente.'));
      } else if (statusCode == 409) {
        final updated = inspection.copyWith(status: 'conflict');
        await _repository.saveInspection(updated);
        _inspectionCubit.loadInspections();
        emit(SyncFailed('El servidor rechazó la sincronización por un conflicto de datos.'));
      } else {
        emit(SyncFailed('Fallo temporal del servidor ($statusCode). Reintentando luego.'));
      }
    } catch (e) {
      emit(SyncFailed('Error de red al sincronizar registro: $e'));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
