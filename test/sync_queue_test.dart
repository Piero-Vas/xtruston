import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:test_flutter/domain/models/inspection_model.dart';
import 'package:test_flutter/domain/ports/api_service_port.dart';
import 'package:test_flutter/domain/ports/connectivity_service_port.dart';
import 'package:test_flutter/domain/ports/inspection_repository_port.dart';
import 'package:test_flutter/infrastructure/adapters/hive_inspection_repository.dart';
import 'package:test_flutter/logic/cubits/inspection_cubit.dart';
import 'package:test_flutter/logic/cubits/sync_cubit.dart';

// --- MOCKS MANUALES ---

class FakeBox implements Box {
  final Map<dynamic, dynamic> _data = {};

  @override
  Iterable get values => _data.values;

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) => _data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key);
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockApiService implements ApiServicePort {
  final List<InspectionModel> uploadedInspections = [];
  int mockStatusCode = 200;

  @override
  Future<int> uploadInspection(InspectionModel inspection) async {
    uploadedInspections.add(inspection);
    return mockStatusCode;
  }
}

class MockConnectivityService implements ConnectivityServicePort {
  final _controller = StreamController<bool>.broadcast();
  bool isConnectedValue = true;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> get isConnected async => isConnectedValue;

  void emitConnection(bool isOnline) {
    isConnectedValue = isOnline;
    _controller.add(isOnline);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late FakeBox fakeBox;
  late InspectionRepositoryPort repository;
  late MockApiService mockApiService;
  late MockConnectivityService mockConnectivity;
  late InspectionCubit inspectionCubit;
  late SyncCubit syncCubit;

  setUp(() {
    fakeBox = FakeBox();
    repository = HiveInspectionRepository(fakeBox);
    mockApiService = MockApiService();
    mockConnectivity = MockConnectivityService();
    inspectionCubit = InspectionCubit(repository);
    syncCubit = SyncCubit(
      repository,
      mockApiService,
      mockConnectivity,
      inspectionCubit,
    );
  });

  tearDown(() {
    mockConnectivity.dispose();
    syncCubit.close();
    inspectionCubit.close();
  });

  group('Sync Queue Offline-First Tests', () {
    final testInspection = InspectionModel(
      id: 'test-1',
      name: 'Planta de Prueba',
      category: 'Seguridad',
      photoPath: 'test_path.png',
      observation: 'Sin observaciones',
      status: 'pending',
      createdAt: DateTime(2026, 1, 1),
    );

    test('1. Test de cola offline: Se guarda en Hive con estado pending sin llamadas al API', () async {
      // Configurar estado offline
      mockConnectivity.isConnectedValue = false;

      // Guardar inspección e iniciar flujo
      await inspectionCubit.addInspection(testInspection);
      await syncCubit.syncPendingQueue();

      // Verificar persistencia local
      final localData = await repository.getInspection('test-1');
      expect(localData, isNotNull);
      expect(localData!.status, 'pending');

      // Verificar que NO se intentó subir al API
      expect(mockApiService.uploadedInspections.isEmpty, true);
    });

    test('2. Test de sincronización inmediata: Se guarda en Hive con estado synced cuando está online', () async {
      // Configurar estado online
      mockConnectivity.isConnectedValue = true;
      mockApiService.mockStatusCode = 200;

      // Registrar inspección y sincronizar
      await inspectionCubit.addInspection(testInspection);
      await syncCubit.syncPendingQueue();

      // Verificar persistencia local actualizada a synced
      final localData = await repository.getInspection('test-1');
      expect(localData, isNotNull);
      expect(localData!.status, 'synced');

      // Verificar que se llamó al API con el registro correcto
      expect(mockApiService.uploadedInspections.length, 1);
      expect(mockApiService.uploadedInspections.first.id, 'test-1');
    });

    test('3. Test de recuperación automática: Sincroniza ítems pendientes al transicionar a online', () async {
      // Empezamos sin conexión y guardamos la inspección
      mockConnectivity.isConnectedValue = false;
      await inspectionCubit.addInspection(testInspection);

      // Verificamos que inicialmente está pendiente
      var localData = await repository.getInspection('test-1');
      expect(localData!.status, 'pending');
      expect(mockApiService.uploadedInspections.isEmpty, true);

      // Cambiamos a conectado y emitimos el evento de reconexión
      mockConnectivity.isConnectedValue = true;
      mockApiService.mockStatusCode = 200;
      
      // Simulamos que el listener detecta la red activa
      mockConnectivity.emitConnection(true);

      // Esperamos un ciclo de microtareas para dejar que se procese el StreamSubscription de SyncCubit
      await Future.delayed(const Duration(milliseconds: 100));

      // Verificar que se auto-sincronizó
      localData = await repository.getInspection('test-1');
      expect(localData!.status, 'synced');
      expect(mockApiService.uploadedInspections.length, 1);
    });

    test('4. Test de conflicto (Bonus): Cambia estado local a conflict si el servidor devuelve 409', () async {
      mockConnectivity.isConnectedValue = true;
      mockApiService.mockStatusCode = 409; // Conflicto

      await inspectionCubit.addInspection(testInspection);
      await syncCubit.syncPendingQueue();

      // Verificar que el estado cambió a conflict
      final localData = await repository.getInspection('test-1');
      expect(localData, isNotNull);
      expect(localData!.status, 'conflict');
    });
  });
}
