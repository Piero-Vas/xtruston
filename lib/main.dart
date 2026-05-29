import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_flutter/domain/ports/api_service_port.dart';
import 'package:test_flutter/domain/ports/connectivity_service_port.dart';
import 'package:test_flutter/domain/ports/inspection_repository_port.dart';
import 'package:test_flutter/infrastructure/adapters/connectivity_service_impl.dart';
import 'package:test_flutter/infrastructure/adapters/hive_inspection_repository.dart';
import 'package:test_flutter/infrastructure/adapters/http_api_service.dart';
import 'package:test_flutter/logic/cubits/inspection_cubit.dart';
import 'package:test_flutter/logic/cubits/sync_cubit.dart';
import 'package:test_flutter/presentation/theme/app_theme.dart';
import 'package:test_flutter/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive para Flutter
  await Hive.initFlutter();

  // Inicializar el adaptador de repositorio abriendo la caja local
  final HiveInspectionRepository inspectionRepository = await HiveInspectionRepository.init();

  // Crear instancias de los adaptadores concretos
  final ApiServicePort apiService = HttpApiService();
  final ConnectivityServicePort connectivityService = ConnectivityServiceImpl();

  runApp(
    MyApp(
      inspectionRepository: inspectionRepository,
      apiService: apiService,
      connectivityService: connectivityService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final InspectionRepositoryPort inspectionRepository;
  final ApiServicePort apiService;
  final ConnectivityServicePort connectivityService;

  const MyApp({
    super.key,
    required this.inspectionRepository,
    required this.apiService,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    // Inyectamos las dependencias globales en el árbol de widgets
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: inspectionRepository),
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: connectivityService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<InspectionCubit>(
            create: (context) => InspectionCubit(inspectionRepository),
          ),
          BlocProvider<SyncCubit>(
            create: (context) => SyncCubit(
              inspectionRepository,
              apiService,
              connectivityService,
              context.read<InspectionCubit>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Inspecciones Offline-First',
          debugShowCheckedModeBanner: false,
          
          theme: AppTheme.lightTheme,
          
          // Pantalla Principal
          home: const HomePage(),
        ),
      ),
    );
  }
}
