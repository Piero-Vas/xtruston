import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/main.dart';
import 'package:test_flutter/domain/ports/inspection_repository_port.dart';
import 'package:test_flutter/domain/ports/api_service_port.dart';
import 'package:test_flutter/domain/ports/connectivity_service_port.dart';
import 'package:test_flutter/infrastructure/adapters/hive_inspection_repository.dart';
import 'package:test_flutter/infrastructure/adapters/http_api_service.dart';
import 'package:test_flutter/infrastructure/adapters/connectivity_service_impl.dart';
import 'sync_queue_test.dart'; // Importamos FakeBox para reutilizarlo

void main() {
  testWidgets('App loads and shows empty state', (WidgetTester tester) async {
    // Inicializar dependencias fake implementando los puertos
    final fakeBox = FakeBox();
    final InspectionRepositoryPort repository = HiveInspectionRepository(fakeBox);
    final ApiServicePort apiService = HttpApiService(client: null);
    final ConnectivityServicePort connectivityService = ConnectivityServiceImpl(connectivity: null);

    // Construir la app
    await tester.pumpWidget(
      MyApp(
        inspectionRepository: repository,
        apiService: apiService,
        connectivityService: connectivityService,
      ),
    );

    // Reconstruir un cuadro para dejar inicializar cubits
    await tester.pumpAndSettle();

    // Verificar que se muestra el título de la página principal
    expect(find.text('Inspecciones de Campo'), findsOneWidget);

    // Verificar que se muestra el estado vacío inicial
    expect(find.text('No hay inspecciones'), findsOneWidget);
  });
}
